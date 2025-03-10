
#===============================================================================
# Party pop-up panel
#===============================================================================
class PokemonBoxPartySprite < SpriteWrapper
    def initialize(party, viewport = nil)
        super(viewport)
        @party = party
        party_path = "Graphics/Pictures/Storage/overlay_party"
        party_path += "_dark" if darkMode?
        @boxbitmap = AnimatedBitmap.new(party_path)
        @pokemonsprites = []
        for i in 0...Settings::MAX_PARTY_SIZE
            @pokemonsprites[i] = nil
            pokemon = @party[i]
            @pokemonsprites[i] = PokemonBoxIcon.new(pokemon, viewport) if pokemon
        end
        @contents = BitmapWrapper.new(172, 352)
        self.bitmap = @contents
        self.x = 182
        self.y = Graphics.height - 352
        pbSetSystemFont(bitmap)
        refresh
    end

    def dispose
        for i in 0...Settings::MAX_PARTY_SIZE
            @pokemonsprites[i].dispose if @pokemonsprites[i]
        end
        @boxbitmap.dispose
        @contents.dispose
        super
    end

    def x=(value)
        super
        refresh
    end

    def y=(value)
        super
        refresh
    end

    def color=(value)
        super
        for i in 0...Settings::MAX_PARTY_SIZE
            if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
                @pokemonsprites[i].color = pbSrcOver(@pokemonsprites[i].color, value)
            end
        end
    end

    def visible=(value)
        super
        for i in 0...Settings::MAX_PARTY_SIZE
            @pokemonsprites[i].visible = value if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        end
    end

    def getPokemon(index)
        return @pokemonsprites[index]
    end

    def setPokemon(index, sprite)
        @pokemonsprites[index] = sprite
        @pokemonsprites.compact!
        refresh
    end

    def grabPokemon(index, arrow)
        sprite = @pokemonsprites[index]
        if sprite
            arrow.grab(sprite)
            @pokemonsprites[index] = nil
            @pokemonsprites.compact!
            refresh
        end
    end

    def deletePokemon(index)
        @pokemonsprites[index].dispose
        @pokemonsprites[index] = nil
        @pokemonsprites.compact!
        refresh
    end

    def refresh
        @contents.blt(0, 0, @boxbitmap.bitmap, Rect.new(0, 0, 172, 352))
        pbDrawTextPositions(bitmap, [
                                [_INTL("Back"), 86, 240, 2, Color.new(248, 248, 248), Color.new(80, 80, 80), 1],
                            ])
        xvalues = []   # [18, 90, 18, 90, 18, 90]
        yvalues = []   # [2, 18, 66, 82, 130, 146]
        for i in 0...Settings::MAX_PARTY_SIZE
            xvalues.push(18 + 72 * (i % 2))
            yvalues.push(2 + 16 * (i % 2) + 64 * (i / 2))
        end
        for j in 0...Settings::MAX_PARTY_SIZE
            @pokemonsprites[j] = nil if @pokemonsprites[j] && @pokemonsprites[j].disposed?
        end
        @pokemonsprites.compact!
        for j in 0...Settings::MAX_PARTY_SIZE
            sprite = @pokemonsprites[j]
            next unless sprite && !sprite.disposed?
            sprite.viewport = viewport
            sprite.x = self.x + xvalues[j]
            sprite.y = self.y + yvalues[j]
            sprite.z = 0
        end
    end

    def update
        super
        for i in 0...Settings::MAX_PARTY_SIZE
            @pokemonsprites[i].update if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        end
    end
end
