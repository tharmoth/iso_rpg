class_name RPGCharacter extends Node

##############
# Base stats #
##############
var exceptional_strength : int = Items.roll_dice("1d100")
var strength     : int = Items.roll_dice("3d6")
var dexterity    : int = Items.roll_dice("3d6")
var constitution : int = Items.roll_dice("3d6") :
	set(value):
		constitution = value
		health = max_health
var intelligence : int = Items.roll_dice("3d6")
var wisdom       : int = Items.roll_dice("3d6")
var charisma     : int = Items.roll_dice("3d6")

###########
# Choices #
###########
enum ALIGNMENT {LAWFUL_GOOD, GOOD, CHAOTIC_GOOD, LAWFUL_NEUTRAL, TRUE_NEUTRAL, CHAOTIC_NEUTRAL, LAWFUL_EVIL, EVIL, CHAOTIC_EVIL}
var alignment : ALIGNMENT = ALIGNMENT.TRUE_NEUTRAL

var character_class : String = "fighter"

##################
# Class Features #
##################
var hit_die  : String = "d10"

##############
# Calculated #
##############
var hd_max_health : int = Items.roll_dice("1" + hit_die):
	set(value):
		hd_max_health = value
		health = max_health
var max_health : int = hd_max_health + constitution_bonus_health():
	get:
		return hd_max_health + constitution_bonus_health()
	set(value):
		push_error("Max Health is a calculated field!")
signal xp_gained()
var xp : int = 0 :
	set(value):
		xp = value
		xp_gained.emit()
signal leveled_up()
var level : int = 1

############
# Variable #
############
signal health_changed(old_health, new_health)
var health : int = hd_max_health + constitution_bonus_health():
	set(new_health):
		var old_health = health
		health = new_health
		health_changed.emit(old_health, health)
var weight : int = get_carry_weight()

#############
# Equipment #
#############
signal equipment_changed(slot, new_value)
var weapon    : String = Items.empty_slot("weapon") :
	set(value):
		weapon = value
		equipment_changed.emit("weapon", weapon)
var armor     : String = Items.empty_slot("armor") :
	set(value):
		armor = value
		equipment_changed.emit("armor", armor)
var shield    : String = Items.empty_slot("shield") :
	set(value):
		shield = value
		equipment_changed.emit("shield", shield)
var helmet    : String = Items.empty_slot("helmet") :
	set(value):
		helmet = value
		equipment_changed.emit("helmet", helmet)
var gloves    : String = Items.empty_slot("gloves") :
	set(value):
		gloves = value
		equipment_changed.emit("gloves", gloves)
var ring_1    : String = Items.empty_slot("ring_1") :
	set(value):
		ring_1 = value
		equipment_changed.emit("ring_1", ring_1)
var ring_2    : String = Items.empty_slot("ring_2") :
	set(value):
		ring_2 = value
		equipment_changed.emit("ring_2", ring_2)
var necklace  : String = Items.empty_slot("necklace") :
	set(value):
		necklace = value
		equipment_changed.emit("necklace", necklace)
var belt      : String = Items.empty_slot("belt") :
	set(value):
		belt = value
		equipment_changed.emit("belt", belt)
var cape      : String = Items.empty_slot("cape") :
	set(value):
		cape = value
		equipment_changed.emit("cape", cape)
var boots      : String = Items.empty_slot("boots") :
	set(value):
		cape = value
		equipment_changed.emit("boots", boots)
var quiver      : Array  = ["", "", ""]
var inventory   : Array  = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
var quick_slots : Array  = ["", "", ""]
var consumable : String = "" :
	set(value):
		consume()
var gold : int = 0 :
	set(value):
		gold = value
		equipment_changed.emit("gold", gold)

func _init():
	hd_max_health = hd_max_health
	if inventory == []:
		inventory.resize(16)
		inventory.fill("")
	if quiver == []:
		quiver.resize(3)
		quiver.fill("")	

	
func attack() -> int:
	var roll = Items.roll_dice("1d20")
	if roll == 20:
		return UTILS.INFINITY
	else:
		return roll + Database.get_class_data(character_class, level, "bab") + Database.get_str_data("strength", strength, exceptional_strength, "attack")
	
func damage() -> int:
	var weapon_data = ItemDatabase.get_item(weapon)
	if weapon_data == {}:
		return 1
	else:
		return Items.roll_dice(weapon_data.dice) + Database.get_str_data("strength", strength, exceptional_strength, "damage")
		
func ac() -> int:
	var armor_data = ItemDatabase.get_item(armor)
	var ac_from_armor = 10
	if armor_data != {}:
		ac_from_armor = armor_data.ac
		
	var shield_data = ItemDatabase.get_item(shield)
	var ac_from_shield = 0
	if shield_data != {}:
		ac_from_shield = shield_data.ac_bonus
		
	return ac_from_armor + ac_from_shield + Database.get_stat_data("dexterity", dexterity, "ac")
	
func equip(item_slot : String, item_name : String) -> void:
	if item_name == "":
		if item_slot == "weapon":
			item_name = "unarmed"
		elif item_slot == "armor":
			item_name = "clothing"
		elif item_slot == "shield":
			item_name = "unarmed_oh"
	set(item_slot, item_name)
	weight = get_carry_weight()
	
func add_item_to_inventory(item : String) -> bool:
	if item != null and has_open_inventory_slot():
		return add_item_to_inventory_slot(inventory.find(""), item)
	else:
		GUI.post("Cant add " + ItemDatabase.get_item(item).name + " to inventory. No Space!")
		return false

func has_open_inventory_slot() -> bool:
	return inventory.find("") > -1

func open_inventory_slots() -> int:
	return inventory.count("")

func add_item_to_inventory_slot(slot : int, item : String) -> bool:
	if item != null and slot > -1:
		inventory[slot] = item
		equipment_changed.emit("inventory" + str(slot), item)
		weight = get_carry_weight()
		return true
	else:
		return false

func add_item_to_quick_slot(slot : int, item : String) -> bool:
	if item != null and slot > -1:
		quick_slots[slot] = item
		equipment_changed.emit("quick" + str(slot), item)
		weight = get_carry_weight()
		return true
	else:
		return false	
	
func consume() -> void:
	var healing = min(Items.roll_dice("2d4+1"), max_health - health)
	GUI.post(get_parent().display_name + " drank a potion healing " + str(healing) + " hitpoints!")
	health += healing
		
func constitution_bonus_health() -> int:
	return level * int(Database.get_stat_data("constitution", constitution, "hp"))
	
func can_level_up():
	return xp >= Database.get_class_data(character_class, level + 1, "xp")
	
func level_up() -> void:
	if xp < Database.get_class_data(character_class, level + 1, "xp"):
		print(get_parent().display_name + " doesn't yet have enough xp to level up!")
	level += 1
	var new_health = Items.roll_dice("1" + hit_die)
	GUI.post(get_parent().display_name + " gained " + str(new_health + constitution_bonus_health() / level) + " health from leveling up!")
	hd_max_health += new_health
	leveled_up.emit()

func heal_to_full():
	health = max_health

func get_all_items() -> Array:
	var valuables = []

	if ItemDatabase.get_item_value(weapon) > -1:
		valuables.append(weapon)
	if ItemDatabase.get_item_value(armor) > -1:
		valuables.append(armor)
	if ItemDatabase.get_item_value(shield) > -1:
		valuables.append(shield)
		
	for item in inventory:
		if item != "":
			valuables.append(item)
			
	for item in quick_slots:
		if item != "":
			valuables.append(item)
	
	if gold > 0:
		valuables.append(gold)
	
	return valuables
	
func strip() -> void:
	var valuables = []
	
	inventory.fill("")
	quiver.fill("")
	quick_slots.fill("")
	equip("weapon", "")
	equip("armor", "")
	equip("shield", "")
	gold = 0

func print_stats(to_console : bool) -> String:
	var string = ""
	
	string += "level        : " + str(level) + "\n"
	string += "xp           : " + str(xp) + "\n"
	string += "gold         : " + str(gold) + "\n"
	string += "party gold   : " + str(Party.gold) + "\n"
	string += "\n"

	if strength == 18:
		string += "strength     : " + str(strength) + "/" + str(exceptional_strength) + "\n"
	else:
		string += "strength     : " + str(strength) + "\n"

	string += "dexterity    : " + str(dexterity) + "\n"
	string += "constitution : " + str(constitution) + "\n"
#	string += "intelligence : " + str(intelligence) + "\n"
#	string += "wisdom       : " + str(wisdom) + "\n"
	string += "charisma     : " + str(charisma) + "\n"
	string += "\n"
	string += "hitpoints    : " + str(health) + ", from rolls " + str(hd_max_health) + ", from constitution " + str(constitution_bonus_health()) +"\n"
	string += "ac           : " + str(ac()) + "\n"
	string += "attack bonus : " + str(Database.get_class_data(character_class, level, "bab") + Database.get_str_data("strength", strength, exceptional_strength, "attack")) + "\n"
	var weapon_data = ItemDatabase.get_item(weapon)
	var attack_damage : String = "1"
	if weapon_data != {}:
		attack_damage = str(weapon_data.dice) + "+" + str(Database.get_str_data("strength", strength, exceptional_strength, "damage"))
	string += "attack damage: " + attack_damage + "\n"
	string += "\n"

	string += "bab          : " + str(Database.get_class_data("fighter", level, "bab")) + "\n"
	string += "str atk bonus: " + str(Database.get_str_data("strength", strength, exceptional_strength, "attack")) + "\n"
	string += "str dmg bonus: " + str(Database.get_str_data("strength", strength, exceptional_strength, "damage")) + "\n"
	string += "dex ac bonus : " + str(Database.get_stat_data("dexterity", dexterity, "ac")) + "\n"
	
	weight = get_carry_weight()
	string += "carry weight : " + str(weight) + "/"+str(Database.get_str_data("strength", strength, exceptional_strength, "max")) + "\n"
	if to_console:
		print(string)
		print("attack roll:   " + str(attack()))
		print("damage roll:   " + str(damage()))
	
	return string

func get_carry_weight():
	var temp_weight = 0
	for item in get_all_items():
		if item is String: # Else is gold
			temp_weight += ItemDatabase.get_item(item).weight
	return temp_weight
		
func save():
	return {
		# Stats
		"exceptional_strength" : exceptional_strength,
		"strength" : strength,
		"dexterity" : dexterity,
		"constitution" : constitution,
		"intelligence" : intelligence,
		"wisdom" : wisdom,
		"charisma" : charisma,

		# Choices
		"alignment" : alignment,
		"character_class" : character_class,
		
		# Level Related Data
		"hd_max_health" : hd_max_health,
		"xp" : xp,
		"level" : level,
		"health" : health if health > 0 else UTILS.MINUS_INFINITY,
		
		# Equipment
		"weapon" : weapon,
		"armor" : armor,
		"shield" : shield,
		"helmet" : helmet,
		"gloves" : gloves,
		"ring_1" : ring_1,
		"ring_2" : ring_2,
		"necklace" : necklace,
		"belt" : belt,
		"cape" : cape,
		"boots" : boots,
		"inventory" : inventory,
		"quiver" : quiver,
		"quick_slots" : quick_slots,
		"gold" : gold,
	}
