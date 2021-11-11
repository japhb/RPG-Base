% Containing or carrying


`RPG::Base::ThingContainer` is, as the name implies, a container for things.
But while it's obvious that a container should be able to efficiently know all
the things it contains, it's not obvious whether each thing should track its
container.  Furthermore it's not obvious whether "containing" is a sufficiently
generic concept that it can be bent to also handle carrying, wearing,
supporting, etc.

Let's take the second question first, which seems to hinge on a simple
difference: whether more than one creature or thing can work together on it.
Full physical containment normally just nests (e.g. a gem contained in a
necklace contained in a velvet bag contained in a jewelry box contained in a
loot bag contained in a wagon), but more than one creature will often be working
together to carry something heavy (such as two adventurers carrying a chest
together), and more than one thing can together support another thing (four legs
together supporting a table).  "Wearing" straddles the boundary.  Normally
clothing, armor, and accessories are each worn by a single creature at a time,
though there are exceptions -- two people might wear a zebra suit together.
Still, even this case could instead be seen as one creature wearing the top
section plus one wearing the bottom section -- or even flipping the subject and
object and seeing it as one suit containing both people.

The question of whether a thing should remember its container is interesting.
Clearly if the game limits itself to complete physical containment (a thing is
either entirely inside or entirely outside a given container), a quick way of
finding any object's container is useful and easy to implement as a single
"container" attribute per thing.  However if the game supports either partial
containment or containment by non-physical and thus possibly overlapping
containers, such as spell effect areas, NPC attention zones, or sections of
different mapping layers, then this containment linkage becomes many to many
and some of the efficiency is lost.  It might still be valuable for each thing
to cache a list of all the containers they are at least partially inside, but
it's not necessarily clear how to structure containment checks to be most
efficient when considering multiple things all within multiple overlapping
non-physical containers.

Still, from a semantic correctness standpoint there is still value in being
able to easily and automatically enforce the simple rule that complete physical
containment means only having one immediate container at a time.  In particular
it's useful if the test for whether an object already is fully contained, and
if so by what container, is very fast.  One escape hatch for this conundrum is
to separate the concepts of full physical containment versus other similar
relationships, and optimize just that particular case separately.

There's an opportunity here to slice things more generally, however.  It may
be useful to generalize the implementation of abstract 1:1, many:1, and
many:many relationships separately, in which case full physical containment
becomes just a particular kind of many:1 relationship, and both semantically
enforced and optimized as such.
