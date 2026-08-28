# Pattern matrix

The decision matrix `codebase-design`'s catalog step reads. It says, for each of the 23
Gang-of-Four patterns, the one thing that matters at design time: **the situation in which that
pattern is the appropriate shape** — its trigger. It does not say what the pattern is or how to
build it; you already know that. A pattern belongs on the table only when its trigger genuinely
describes the boundary in front of you. When none does, the shape is a plain one — that is the
default, not a failure to find a pattern.

Each trigger below is a condition, not a recommendation: reach for the pattern *when* the
condition holds, and not because the catalog lists it.

## Creational — how objects get made

| Pattern | Reach for it when |
|---|---|
| Factory Method | The concrete class to instantiate isn't known until runtime, or subclasses should decide it — and the alternative is a call site hard-coding one specific concrete class it will later have to change. |
| Abstract Factory | You create *families* of related objects that must stay mutually consistent (a matched set), and callers must not accidentally mix members of different families. |
| Builder | Construction takes many optional or step-wise parameters, and a telescoping constructor or a long positional argument list would be unreadable or easy to hold wrong. |
| Prototype | Building a fresh instance is expensive or its concrete type is unknown, and copying an already-configured instance is cheaper or cleaner than reconstructing one. |
| Singleton | Exactly one instance must exist and duplicates would be *incorrect*, not merely wasteful. Rare, and often a smell — prefer passing one shared instance explicitly before reaching here. |

## Structural — how objects compose

| Pattern | Reach for it when |
|---|---|
| Adapter | Two interfaces you don't control must interoperate, and you need to translate one into the shape the other expects without changing either side. |
| Bridge | An abstraction and its implementation each vary on their own axis, and a class-per-combination would explode combinatorially (M×N); separate the axes so each varies alone. |
| Composite | Callers should treat a single object and a tree of objects uniformly through one interface (a part–whole hierarchy). |
| Decorator | You must add responsibilities to individual objects at runtime, in combinations, without a subclass for every combination — keeping the wrapped object's interface intact. |
| Facade | A subsystem is complex but callers need only a narrow entry point; hide the orchestration behind one simple interface. (This is `DEEPENING.md`'s "pull complexity down" move wearing a pattern name.) |
| Flyweight | You hold a very large number of objects whose memory footprint actually bites, and most of their state is intrinsic/shared and can be pooled rather than duplicated. |
| Proxy | You need to control access to an object — lazy initialization, access checks, caching, a stand-in for a remote or heavy resource — behind the same interface it already presents. |

## Behavioral — how objects interact

| Pattern | Reach for it when |
|---|---|
| Chain of Responsibility | A request should be handled by one of several handlers chosen at runtime, and the sender must not know which; handlers form a pipeline, each free to handle or pass on. |
| Command | You need to treat an operation as a first-class object — to queue it, log it, parameterize it, or make it undoable. |
| Iterator | Callers must traverse a collection's elements without the collection exposing its internal representation. |
| Mediator | A set of objects communicate in a tangled many-to-many web; route their interaction through one mediator so each knows only the mediator, cutting the coupling. |
| Memento | You must capture and later restore an object's internal state (undo, snapshots) without exposing that state through its public interface. |
| Observer | A change in one object must notify an open-ended set of dependents that the subject must not know the concrete types of. |
| State | An object's behavior changes with its internal state, and the alternative is sprawling conditionals switching on a state field; make each state its own object. |
| Strategy | Several interchangeable algorithms or policies exist for one job and the choice should be swappable, replacing a conditional that selects behavior with a pluggable one. |
| Template Method | Several variants share one algorithm skeleton but differ in specific steps; fix the skeleton in one place and let the variants fill only the steps that differ. |
| Visitor | You need to add new operations across a *stable* object structure without editing its classes each time; move the operation out into a visitor. |
| Interpreter | You have a small, well-defined grammar to evaluate and representing its sentences as an object tree earns its keep. Rare — reach for a real parser before this at any scale. |
