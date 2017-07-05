use RPG::Base::Thing;
use RPG::Base::ThingContainer;


class RPG::Base::Container is RPG::Base::Thing
 does RPG::Base::ThingContainer {
    method gist() {
        "$.name ({ self.^name }"
            ~ (" in $.container.^name() '$.container'" if $.container)
            ~ (" containing @.contents.join(', ')"     if @.contents)
            ~ ")"
    }

    method Str() {
        $.name ~ (" (contents: @.contents.join(', '))" if @.contents)
    }
}
