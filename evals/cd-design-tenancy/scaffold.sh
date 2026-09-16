#!/usr/bin/env bash
# Shared minimal fixture: a small, believable public-library app repo so the
# pipeline entrances have real context to engage with (ask grounded discovery
# questions, reproduce a defect, verify a review claim) instead of spiralling on
# an empty working directory. Copied into each routing case as scaffold.sh.
set -euo pipefail

git init -q
git config user.email "eval@example.com"
git config user.name "eval"
git config commit.gpgsign false
mkdir -p src

cat > README.md <<'MD'
# Bookery

Internal platform for a public library system: book catalog, study-room
scheduling, and member onboarding. PHP 8.2, thin service layer over PDO.

## Layout
- `src/CatalogInventory.php` — the book catalog page/service.
- `src/RoomScheduler.php` — assigns study rooms to bookings by time window.
- `src/MemberOnboarding.php` — the multi-step new-member onboarding flow.
- `src/ShelfPlanner.php` — orders books for a display; retries the recs call.
- `src/BackoffRetry.php` — shared exponential-backoff retry helper.
MD

cat > composer.json <<'JSON'
{
  "name": "bookery/app",
  "require": { "php": ">=8.2" },
  "autoload": { "psr-4": { "App\\": "src/" } }
}
JSON

cat > src/CatalogInventory.php <<'PHP'
<?php
namespace App;
final class CatalogInventory {
    public function __construct(private \PDO $db) {}
    public function add(string $isbn, string $title, string $sectionId): void {
        $s = $this->db->prepare('INSERT INTO books(isbn,title,section_id) VALUES(:i,:t,:section)');
        $s->execute(['i' => $isbn, 't' => $title, 'section' => $sectionId]);
    }
    public function listForSection(string $sectionId): array {
        $s = $this->db->prepare('SELECT isbn,title FROM books WHERE section_id = :section');
        $s->execute(['section' => $sectionId]);
        return $s->fetchAll(\PDO::FETCH_ASSOC);
    }
}
PHP

cat > src/RoomScheduler.php <<'PHP'
<?php
namespace App;
final class RoomScheduler {
    public function __construct(private \PDO $db) {}
    /** Assigns a room to a booking's time window. */
    public function assign(string $bookingId, string $roomId, string $start, string $end): void {
        // NOTE: assigns without checking whether the room already has an
        // overlapping booking — callers assume the room is free.
        $s = $this->db->prepare(
            'INSERT INTO bookings(booking_id,room_id,win_start,win_end) VALUES(:b,:r,:a,:c)'
        );
        $s->execute(['b' => $bookingId, 'r' => $roomId, 'a' => $start, 'c' => $end]);
    }
}
PHP

cat > src/MemberOnboarding.php <<'PHP'
<?php
namespace App;
final class MemberOnboarding {
    public function __construct(private \PDO $db) {}
    public function start(string $fullName, string $email): string { return 'onb_' . substr(md5($email), 0, 8); }
    public function submitDocs(string $onboardingId, array $docs): void { /* stores uploaded ID docs */ }
    public function activate(string $onboardingId): void { /* issues the library card */ }
}
PHP

cat > src/BackoffRetry.php <<'PHP'
<?php
namespace App;
final class BackoffRetry {
    /** Runs $op, retrying with exponential backoff up to $max attempts. */
    public static function run(callable $op, int $max = 5, int $baseMs = 100): mixed {
        $attempt = 0;
        while (true) {
            try { return $op(); }
            catch (\Throwable $e) {
                if (++$attempt >= $max) { throw $e; }
                usleep($baseMs * (2 ** ($attempt - 1)) * 1000);
            }
        }
    }
}
PHP

cat > src/ShelfPlanner.php <<'PHP'
<?php
namespace App;
final class ShelfPlanner {
    public function __construct(private RecsClient $recs) {}
    public function order(array $books): array {
        // Retries the recs call with its own hand-rolled loop.
        $tries = 0;
        while (true) {
            try { return $this->recs->rank($books); }
            catch (\Throwable $e) { if (++$tries >= 3) { throw $e; } sleep(1); }
        }
    }
}
PHP

git add -A
git commit -qm "Bookery: catalog, scheduling, onboarding, shelving"
echo "fixture repo ready"
