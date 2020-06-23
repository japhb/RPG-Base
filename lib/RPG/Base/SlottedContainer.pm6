use RPG::Base::ThingContainer;


role RPG::Base::SlottedContainer {...};


# Exceptions specific to this role
class X::RPG::Base::SlottedContainer::SlotDoesNotExist is Exception {
    has RPG::Base::SlottedContainer $.container is required;
    has Str:D                       $.slot-name is required;

    method message() {
        "$.container.^name() '$.container' does not have a '$.slot-name' slot"
    }
}

class X::RPG::Base::SlottedContainer::SlotAlreadyExists is Exception {
    has RPG::Base::SlottedContainer $.container is required;
    has Str:D                       $.slot-name is required;

    method message() {
        "$.container.^name() '$.container' already has a '$.slot-name' slot"
    }
}

class X::RPG::Base::SlottedContainer::NoSlotSpecified is Exception {
    has RPG::Base::SlottedContainer $.container is required;

    method message() {
        "Must specify a slot within $.container.^name() '$.container' to act on"
    }
}


#| A container with multiple slots/compartments/attachment points
role RPG::Base::SlottedContainer does RPG::Base::ThingContainer {
    has RPG::Base::ThingContainer %.slots;

    # Invariant checkers
    method !throw-if-slot-exists($slot-name) {
        X::RPG::Base::SlottedContainer::SlotAlreadyExists.new(:$slot-name, :container(self)).throw
            if self.has-slot($slot-name);
    }

    method !throw-unless-slot-exists($slot-name) {
        X::RPG::Base::SlottedContainer::SlotDoesNotExist.new(:$slot-name, :container(self)).throw
            unless self.has-slot($slot-name);
    }


    #| Check if slot exists already
    method has-slot(Str:D $slot-name) {
        %.slots{$slot-name}:exists
    }

    #| Add a new slot
    method add-slot(Str:D $slot-name, RPG::Base::ThingContainer:D $new-slot) {
        self!throw-if-slot-exists($slot-name);

        %.slots{$slot-name} = $new-slot;
    }

    #| Check if a thing exists in a particular slot
    method slot-contains(Str:D $slot-name, RPG::Base::Thing:D $thing) {
        self!throw-unless-slot-exists($slot-name);

        %.slots{$slot-name}.contains($thing)
    }

    #| Add a thing to a slot
    method add-thing-to-slot(Str:D $slot-name, RPG::Base::Thing:D $thing) {
        self!throw-unless-slot-exists($slot-name);

        %.slots{$slot-name}.add-thing($thing);
    }

    #| Remove a thing from a slot
    method remove-thing-from-slot(Str:D $slot-name, RPG::Base::Thing:D $thing) {
        self!throw-unless-slot-exists($slot-name);

        %.slots{$slot-name}.remove-thing($thing);
    }


    ### ThingContainer API

    #| Contents from all slots combined
    method contents() {
        flat %.slots.values».contents.Slip
    }

    #| Check if a thing exists in any known slot
    method contains(RPG::Base::Thing:D $thing) {
        so %.slots.values.first(*.contains($thing))
    }

    #| Add a thing to a slot (ThingContainer-compatible API)
    multi method add-thing(RPG::Base::Thing:D $thing, Str:D :$slot!) {
        self.add-thing-to-slot($slot, $thing);
    }

    #| Block attempts to add a thing without specifying a slot
    multi method add-thing(RPG::Base::Thing:D $thing) {
        X::RPG::Base::SlottedContainer::NoSlotSpecified.new(:container(self)).throw;
    }

    #| Remove a thing from wherever it might be stowed
    method remove-thing(RPG::Base::Thing:D $thing) {
        for %.slots.values -> $slot {
            return $slot.remove-thing($thing) if $slot.contains($thing);
        }

        X::RPG::Base::ThingContainer::NotContained.new(:$thing, :container(self)).throw;
    }

    #| Clone fresh copies of the slots and contents in each slot
    method instantiate-contents() {
        %!slots{$_} .= clone  for %!slots.keys;
        .instantiate-contents for %!slots.values;
    }
}
