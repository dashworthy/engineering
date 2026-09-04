# OroCommerce — framework idiom checklist

The Oro-platform lens for the framework best-practices facet. OroCommerce is a Symfony
application, but these classes of defect are specific to the Oro platform's own extension
mechanisms — not generic Symfony idioms (`symfony.md`'s job), not the generic reinvention/
inefficiency classes Novelty and Technical already own. The reach is the diff: a pattern visible
in the changed code, not a proactive audit of the whole application. Authored directly from
well-established public Oro platform conventions — no Boost-style source material exists for this
stack. Contents:

- Entity extension
- Workflow/process idioms
- Layout system idioms
- DataGrid idioms
- Extension points
- Authorization idioms
- What is not a finding

## Entity extension

Oro's platform ships its own field-extension system precisely so a customization survives a
platform upgrade instead of colliding with it.

- **A vendor/platform entity edited directly** to add a field, instead of an extend field
  (`oro:entity-extend:update-config` + the entity-config annotations) — a direct edit to a
  vendor-owned class is overwritten the next platform upgrade.
- **A custom column added as a raw migration** on a platform entity's table, bypassing the extend
  system entirely — the platform's own entity-config layer never learns the field exists, so
  DataGrids, the API, and the UI's dynamic-field rendering never pick it up.

## Workflow/process idioms

- **Business logic hardcoded into a listener or controller** where the project has an established
  Workflow definition or Process action/condition for the same kind of business rule — the
  platform's workflow engine exists so state-transition logic lives in one inspectable,
  admin-editable place, not scattered across PHP classes.
- **A workflow transition condition duplicated in PHP** where the workflow's own YAML/definition
  already expresses the same condition — the duplication drifts the moment one side changes and
  the other doesn't.

## Layout system idioms

- **A hardcoded Twig template edit** for a storefront/admin customization where Oro's layout
  system (layout XML updates, layout blocks) is the established mechanism for the same kind of
  customization in the surrounding code — a direct template edit breaks the theming and
  block-override extensibility the layout system exists to provide.

## DataGrid idioms

- **A hand-rolled listing query and controller action** built for data a `datagrids.yml`
  configuration would already serve — a DataGrid config gets sorting, filtering, export, and mass
  actions for free; a hand-rolled listing has to reimplement all of it and drifts out of sync with
  how every other listing in the app already behaves.

## Extension points

- **A vendor/platform class edited directly, or copy-pasted and overridden wholesale**, where an
  Oro event listener, an extension bundle's own hook, or a decorator service is the established,
  upgrade-safe mechanism for the same customization — the platform's own extension points exist
  specifically so a customization doesn't have to fork vendor code to land.

## Authorization idioms

- **Authorization checked ad hoc instead of via Oro's own ACL mechanism** — a hand-rolled
  comparison (`if ($user->getId() !== $address->getFrontendOwner()->getId())`) reimplementing
  what an existing `#[Acl]`-annotated action, or an `AuthorizationCheckerInterface`/`AclHelper`
  check, already expresses for that resource. Whether ACL is enforced *at all* is the Security
  facet's question; this is narrower — the platform's own ACL mechanism exists for that resource
  and the change bypasses it.

## What is not a finding

- Whether ACL/authorization is enforced *at all* — that is the **Security** facet's OWASP-class
  finding (A01 Broken Access Control). This facet's question is narrower: when an ACL check is
  present, is it expressed through Oro's own ACL mechanism (`#[Acl]` annotations, the voter
  system), not whether protection exists in the first place.
- A reinvention of an existing Oro/Symfony capability with no Oro-specific placement/shape
  angle — the **Novelty** facet owns reuse over reinvention generically.
- A generic inefficiency (an N+1 shape, an unbounded load) with nothing Oro-specific about it —
  the **Technical** facet already covers inefficient data access in the abstract.
- A generic Symfony idiom with nothing Oro-platform-specific about it (dependency injection,
  routing, Doctrine query shape, Form types) — that belongs to `symfony.md`, not this file. An
  OroCommerce application is Symfony underneath, but this file's scope is the platform layered on
  top of it.
- A style/formatting preference with no correctness or maintainability consequence.
- A pre-existing pattern in a file the change doesn't touch — this facet reviews the diff, not
  the whole application.
- A departure from a rule here that matches an established, consistent convention already used
  elsewhere in the project — consistency with the existing codebase outranks a rule in this file.
