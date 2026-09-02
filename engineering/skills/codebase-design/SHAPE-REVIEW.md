# Shape review

Two **evaluative** lenses — SOLID and the anti-pattern table — run over the two competing shapes
from `DESIGN-IT-TWICE.md`. They don't propose a shape; they catch one that's already wrong. Run
both over each shape before choosing: passing them doesn't make a shape right (still the
three-criteria call), but failing one names a defect those criteria wouldn't. Where a lens fires,
the remedy names a `PATTERN-MATRIX.md` pattern, a `DEEPENING.md` move, or a plain split the
catalog has no name for.

## The SOLID lens — five questions

Each principle is a question asked of an interface, and a "yes" is the violation.

- **Single Responsibility.** Would two unrelated callers want to change this interface for two
  unrelated reasons? If it answers to more than one axis of change, it holds more than one
  responsibility — split it along that seam.
- **Open/Closed.** To add the next variant, does existing code have to be edited, or can the new
  case be *added*? If every new case means reopening the same conditional, the shape isn't open
  to extension — see Strategy / Template Method in the matrix.
- **Liskov Substitution.** Can any implementation stand in for another without a caller
  special-casing which concrete one it holds? If a caller must know the concrete type to use the
  interface correctly, the abstraction is a false one.
- **Interface Segregation.** Does the interface force a caller to depend on methods it never
  calls? An interface where each caller uses a different third of it is several interfaces
  wearing one name — segregate it into role interfaces, one per caller's real need. No GoF
  pattern performs that split; it is a plain decomposition.
- **Dependency Inversion.** Does high-level policy depend on a concrete low-level detail — a
  specific library, transport, or store? If swapping that detail forces a change in the policy,
  invert it behind an interface the policy owns.

## The anti-pattern lens — smell to remedy

Each row is a smell, how it shows *at a boundary* (not in the small), and the remedy — which
names a `PATTERN-MATRIX.md` pattern or a `DEEPENING.md` move. Some restate a `codebase-design`
leak shape in smell vocabulary; that overlap is deliberate — a fat interface simply *is* the ISP
violation above.

| Smell | How it shows at a boundary | Remedy |
|---|---|---|
| God class / object | One interface keeps growing and nearly every call site depends on it. | Split by responsibility (SRP); **Facade** over a coherent subsystem; **Strategy** for the varying policies. |
| Feature envy | A caller reads several fields off a module, then computes what the module itself should have decided. | Move the behavior to the data — a deepening move; where the data is a stable structure the behavior can't move into, gather the operation into a **Visitor**. |
| Shotgun surgery | One conceptual change forces edits across many call sites (the "change inside forces change outside" leak). | Pull the repeated choreography behind the interface (`DEEPENING.md` #2); often **Facade** or **Template Method**. |
| Primitive obsession | Bare strings/ints/maps carry an invariant that every call site re-validates by hand. | A small type that makes the wrong state unrepresentable (misuse resistance); **Builder** where construction is genuinely step-wise. |
| Reinvented / one-off data structure | A boundary introduces a bespoke shape — an ad-hoc dict/tuple/record, or a new class — for a meaning an existing type in the codebase already carries. | Reuse the existing type; where the shape is genuinely new, name it once as a shared type rather than an inline one-off every call site re-learns. Reuse over reinvention is the default; a new structure earns its place against what already exists. |
| Fat / leaky interface | A required call order, or a flag that only makes sense with inside knowledge. | Segregate (ISP); widen responsibility per call (`DEEPENING.md` #2); **Facade**. |
| Long parameter list | A call takes many arguments most callers copy unchanged (`DEEPENING.md` #4's trigger). | Default the common case; a parameter object; **Builder** for step-wise construction. |
| Subclass explosion | Class count multiplies as independent axes cross (a subclass per feature-combination). | **Decorator** to stack responsibilities, or **Bridge** to split the axes. |
| Type/state switch sprawl | The same switch on a type or state field recurs, and a new case means editing each one (OCP). | **Strategy** (behavior selection) or **State** (behavior by internal state); **Visitor** to add operations over a stable structure. |
