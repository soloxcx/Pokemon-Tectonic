module GameData
    class Item
      attr_reader :id
      attr_reader :id_number
      attr_reader :real_name
      attr_reader :real_name_plural
      attr_reader :pocket
      attr_reader :price
      attr_reader :sell_price
      attr_reader :real_description
      attr_reader :field_use
      attr_reader :battle_use
      attr_reader :consumable
      attr_reader :flags
      attr_reader :type
      attr_reader :move
      attr_reader :super
      attr_reader :cut
  
      DATA = {}
      DATA_FILENAME = "items.dat"

      FLAG_INDEX = {}
      FLAGS_INDEX_DATA_FILENAME = "items_indexed_by_flag.dat"

      SCHEMA = {
        "Name"        => [:name,        "s"],
        "NamePlural"  => [:name_plural, "s"],
        "Pocket"      => [:pocket,      "v"],
        "Price"       => [:price,       "u"],
        "SellPrice"   => [:sell_price,  "u"],
        "Description" => [:description, "q"],
        "FieldUse"    => [:field_use,   "e", { "OnPokemon" => 1, "Direct" => 2, "TM" => 3,
                                              "HM" => 4, "TR" => 5 }],
        "BattleUse"   => [:battle_use,  "e", { "OnPokemon" => 1, "OnMove" => 2, "OnBattler" => 3,
                                              "OnFoe" => 4, "Direct" => 5 }],
        "Consumable"  => [:consumable,  "b"],
        "Flags"       => [:flags,       "*s"],
        "Move"        => [:move,        "e", :Move]
      }
  
      extend ClassMethods
      include InstanceMethods
  
      def self.icon_filename(item)
        return "Graphics/Items/back" if item.nil?
        item_data = self.try_get(item)
        return "Graphics/Items/000" if item_data.nil?
        itemID = item_data.id
        # Check for files
        ret = sprintf("Graphics/Items/%s", itemID)
        if itemID == :TAROTAMULET && $PokemonGlobal.tarot_amulet_active
            ret += "_ACTIVE"
        end
        return ret if pbResolveBitmap(ret)
        # Check for TM/HM type icons
        if item_data.is_machine?
          prefix = "machine"
          if item_data.is_HM?
            prefix = "machine_hm"
          elsif item_data.is_TR?
            prefix = "machine_tr"
          end
          move_type = GameData::Move.get(item_data.move).type
          type_data = GameData::Type.get(move_type)
          ret = sprintf("Graphics/Items/%s_%s", prefix, type_data.id)
          return ret if pbResolveBitmap(ret)
          if !item_data.is_TM?
            ret = sprintf("Graphics/Items/machine_%s", type_data.id)
            return ret if pbResolveBitmap(ret)
          end
        end
        return "Graphics/Items/000"
    end
  
      def self.held_icon_filename(item)
        item_data = self.try_get(item)
        return nil if !item_data
        name_base = (item_data.is_mail?) ? "mail" : "item"
        # Check for files
        ret = sprintf("Graphics/Pictures/Party/icon_%s_%s", name_base, item_data.id)
        return ret if pbResolveBitmap(ret)
        return sprintf("Graphics/Pictures/Party/icon_%s", name_base)
      end
  
      def self.mail_filename(item)
        item_data = self.try_get(item)
        return nil if !item_data
        # Check for files
        ret = sprintf("Graphics/Pictures/Mail/mail_%s", item_data.id)
        return pbResolveBitmap(ret) ? ret : nil
      end
  
      def initialize(hash)
        if !hash[:sell_price] && hash[:price]
          hash[:sell_price] = hash[:price] / 2
        end

        @id               = hash[:id]
        @id_number        = hash[:id_number]   || -1
        @real_name        = hash[:name]        || "Unnamed"
        @real_name_plural = hash[:name_plural] || "Unnamed"
        @pocket           = hash[:pocket]      || 1
        @price            = hash[:price]       || 0
        @sell_price       = hash[:sell_price]  || 0
        @real_description = hash[:description] || "???"
        @field_use        = hash[:field_use]   || 0
        @battle_use       = hash[:battle_use]  || 0
        @type             = hash[:type]        || 0
        @flags            = hash[:flags]       || []
        @consumable       = hash[:consumable]
        @consumable       = !is_important? if @consumable.nil?
        @move             = hash[:move]
        @super            = hash[:super]       || false
        @cut              = hash[:cut]       || false

        @flags.each do |flag|
          if FLAG_INDEX.key?(flag)
            FLAG_INDEX[flag].push(@id)
          else
            FLAG_INDEX[flag] = [@id]
          end
        end
      end
  
      # @return [String] the translated name of this item
      def name
        return pbGetMessageFromHash(MessageTypes::Items, @real_name)
      end
  
      # @return [String] the translated plural version of the name of this item
      def name_plural
        return pbGetMessageFromHash(MessageTypes::ItemPlurals, @real_name_plural)
      end
  
      # @return [String] the translated description of this item
      def description
        if is_machine?
            return pbGetMessageFromHash(MessageTypes::MoveDescriptions, GameData::Move.get(@move).real_description)
        else
            return pbGetMessageFromHash(MessageTypes::ItemDescriptions, @real_description)
        end
      end
  
      def is_TM?;                   return @field_use == 3; end
      def is_HM?;                   return @field_use == 4; end
      def is_TR?;                   return @field_use == 6; end
      def is_machine?;              return is_TM? || is_HM? || is_TR?; end

      def is_poke_ball?
        return @flags.include?("PokeBall")
      end

      def is_snag_ball?
        return @flags.include?("SnagBall")
      end

      def is_mail?
        return @flags.include?("Mail")
      end

      def is_icon_mail?
        return @flags.include?("IconMail")
      end

      def is_berry?
        return @flags.include?("Berry")
      end

      def is_clothing?
        return @flags.include?("Clothing")
      end

      def is_choice_locking?
        return @flags.include?("ChoiceLocking")
      end

      def is_no_status_use?
        return @flags.include?("NoStatusUse")
      end

      def is_levitation?
        return @flags.include?("Levitation")
      end

      def is_endure?
        return @flags.include?("Endure")
      end

      def is_weather_rock?
        return @flags.include?("WeatherRock")
      end

      def is_attacker_recoil?
        return @flags.include?("AttackerRecoil")
      end

      def is_herb?
        return @flags.include?("Herb")
      end

      def is_leftovers?
        return @flags.include?("Leftovers")
      end

      def is_pinch?
        return @flags.include?("Pinch")
      end

      def is_key_item?
        return @flags.include?("KeyItem")
      end

      def is_consumable_key_item?
        return @flags.include?("KeyItem") && @consumable
      end

      def is_single_key_item?
        return @flags.include?("KeyItem") && !@consumable
      end

      def is_evolution_stone?
        return @flags.include?("EvolutionStone")
      end

      def is_fossil?
        return @flags.include?("Fossil")
      end

      def is_gem?
        return @flags.include?("TypeGem")
      end

      def is_mega_stone?
        return @flags.include?("MegaStone")
      end

      def is_mulch?
        return @flags.include?("Mulch")
      end
  
      def is_important?
        return true if is_key_item? || is_HM? || is_TM?
        return false
      end

      def is_single_purchase?
        return true if is_single_key_item? || is_HM? || is_TM?
        return false
      end
  
      def can_hold?;           return !is_important? && @pocket == 5; end

      def consumed_after_use?
        return !is_important? && @consumable
      end
  
      def unlosable?(species, ability)
        return false if species == :ARCEUS && ability != :MULTITYPE
        return false if species == :SILVALLY && ability != :RKSSYSTEM
        combos = {
           :ARCEUS   => [:FISTPLATE,   :FIGHTINIUMZ,
                         :SKYPLATE,    :FLYINIUMZ,
                         :TOXICPLATE,  :POISONIUMZ,
                         :EARTHPLATE,  :GROUNDIUMZ,
                         :STONEPLATE,  :ROCKIUMZ,
                         :INSECTPLATE, :BUGINIUMZ,
                         :SPOOKYPLATE, :GHOSTIUMZ,
                         :IRONPLATE,   :STEELIUMZ,
                         :FLAMEPLATE,  :FIRIUMZ,
                         :SPLASHPLATE, :WATERIUMZ,
                         :MEADOWPLATE, :GRASSIUMZ,
                         :ZAPPLATE,    :ELECTRIUMZ,
                         :MINDPLATE,   :PSYCHIUMZ,
                         :ICICLEPLATE, :ICIUMZ,
                         :DRACOPLATE,  :DRAGONIUMZ,
                         :DREADPLATE,  :DARKINIUMZ,
                         :PIXIEPLATE,  :FAIRIUMZ],
           :SILVALLY => [:MEMORYDISC],
           :GIRATINA => [:GRISEOUSORB],
           :GENESECT => [:BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE, :SHOCKDRIVE],
           :KYOGRE   => [:BLUEORB],
           :GROUDON  => [:REDORB]
        }
        return combos[species] && combos[species].include?(@id)
      end

      def legal?(isTrainer = false)
        return false if @cut
        return false if @super && !isTrainer
        return true
      end

      def self.getByFlag(flag)
        if FLAG_INDEX.key?(flag)
          return FLAG_INDEX[flag]
        else
          return []
        end
      end

      def self.load
        super
        const_set(:FLAG_INDEX, load_data("Data/#{self::FLAGS_INDEX_DATA_FILENAME}"))
      end

      def self.save
        super
        save_data(self::FLAG_INDEX, "Data/#{self::FLAGS_INDEX_DATA_FILENAME}")
      end
    end
end

module Compiler
    module_function

  #=============================================================================
  # Compile item data
  #=============================================================================
  def compile_items
    GameData::Item::DATA.clear
    schema = GameData::Item::SCHEMA
    item_names        = []
    item_names_plural = []
    item_descriptions = []
    item_hash         = nil
    idx = 0
    ["PBS/items.txt","PBS/items_super.txt","PBS/items_cut.txt"].each do |path|
      # Read each line of items.txt at a time and compile it into an item
      pbCompilerEachPreppedLine(path) { |line, line_no|
        idx += 1
        if line[/^\s*\[\s*(.+)\s*\]\s*$/]   # New section [item_id]
          # Add previous item's data to records
          GameData::Item.register(item_hash) if item_hash
          # Parse item ID
          item_id = $~[1].to_sym
          if GameData::Item.exists?(item_id)
            raise _INTL("Item ID '{1}' is used twice.\r\n{2}", item_id, FileLineData.linereport)
          end
          # Construct item hash
          item_hash = {
            :id         => item_id,
            :id_number  => idx,
            :cut        => path == "PBS/items_cut.txt",
            :super      => path == "PBS/items_super.txt",
          }
        elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/]   # XXX=YYY lines
          if !item_hash
            raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
          end
          # Parse property and value
          property_name = $~[1]
          line_schema = schema[property_name]
          next if !line_schema
          property_value = pbGetCsvRecord($~[2], line_no, line_schema)
          # Record XXX=YYY setting
          item_hash[line_schema[0]] = property_value
          case property_name
          when "Name"
            item_names.push(item_hash[:name])
          when "NamePlural"
            item_names_plural.push(item_hash[:name_plural])
          when "Description"
            item_descriptions.push(item_hash[:description])
          end
        end
      }
    end
    # Add last item's data to records
    GameData::Item.register(item_hash) if item_hash
    # Save all data
    GameData::Item.save
    MessageTypes.setMessagesAsHash(MessageTypes::Items, item_names)
    MessageTypes.setMessagesAsHash(MessageTypes::ItemPlurals, item_names_plural)
    MessageTypes.setMessagesAsHash(MessageTypes::ItemDescriptions, item_descriptions)
    Graphics.update
  end

  #=============================================================================
  # Save item data to PBS file
  #=============================================================================
  def write_items
    File.open("PBS/items.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each do |i|
        break if i.cut || i.super
        write_item(f,i)
      end
    }
    File.open("PBS/items_super.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each do |i|
        next unless i.super
        write_item(f,i)
      end
    }
    File.open("PBS/items_cut.txt", "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::Item.each do |i|
        next unless i.cut
        write_item(f,i)
      end
    }
    Graphics.update
  end

  def write_item(f,item)
    f.write("\#-------------------------------\r\n")
    f.write(sprintf("[%s]\r\n", item.id))
    f.write(sprintf("Name = %s\r\n", item.real_name))
    f.write(sprintf("NamePlural = %s\r\n", item.real_name_plural))
    f.write(sprintf("Pocket = %d\r\n", item.pocket))
    f.write(sprintf("Price = %d\r\n", item.price))
    f.write(sprintf("SellPrice = %d\r\n", item.sell_price)) if item.sell_price != item.price / 2
    field_use = GameData::Item::SCHEMA["FieldUse"][2].key(item.field_use)
    f.write(sprintf("FieldUse = %s\r\n", field_use)) if field_use
    battle_use = GameData::Item::SCHEMA["BattleUse"][2].key(item.battle_use)
    f.write(sprintf("BattleUse = %s\r\n", battle_use)) if battle_use
    # Assume important items aren't consumable
    # and other items are
    # So only note the exceptions
    if item.is_important?
      f.write(sprintf("Consumable = true\r\n")) if item.consumable
    else
      f.write(sprintf("Consumable = false\r\n")) unless item.consumable
    end
    f.write(sprintf("Flags = %s\r\n", item.flags.join(","))) if item.flags.length > 0
    f.write(sprintf("Move = %s\r\n", item.move)) if item.move
    f.write(sprintf("Description = %s\r\n", item.real_description)) if item.real_description
  end
end