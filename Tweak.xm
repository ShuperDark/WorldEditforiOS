#import "substrate.h"
#include <string>
#include <vector>
#include <mach-o/dyld.h>


struct Level;
struct GuiData;
struct BlockSource;
struct Block;
struct GameMode;

struct Entity {
	char filler[64];
	Level* level;
	char filler2[104];
	BlockSource* region;
};

struct Player : public Entity {
	char filler[4400];

	uintptr_t* inventory;
};

struct BlockID {
	unsigned char value;

	BlockID() { this->value = 1; }
	BlockID(unsigned char val) { this->value = val; }
	BlockID(BlockID const& other) { this->value = other.value; }
	bool operator==(char v) { return this->value == v; }
	bool operator==(int v) { return this->value == v; }
	bool operator==(BlockID v) { return this->value == v.value; }
	operator unsigned char() { return this->value; }
	BlockID& operator=(const unsigned char& v) {
		this->value = v;
		return *this;
	}
};

struct Item {
	uintptr_t** vtable;
	uint8_t maxStackSize;
	int idk;
	std::string atlas;
	int frameCount;
	bool animated;
	short itemId;
	std::string name;
	std::string idk3;
	bool isMirrored;
	short maxDamage;
	bool isGlint;
	bool renderAsTool;
	bool stackedByData;
	uint8_t properties;
	int maxUseDuration;
	bool explodeable;
	bool shouldDespawn;
	bool idk4;
	uint8_t useAnimation;
	int creativeCategory;
	float idk5;
	float idk6;
	uintptr_t* icon;
	char filler[44];
};

struct ItemInstance {
	uint8_t count;
	uint16_t aux;
	uintptr_t* tag;
	Item* item;
	Block* block;
	int idk[3];
};

struct BlockPos {
	int x, y, z;
};

struct Vec3 {
	int x, y, z;
};


static Item** Item$mItems;
static ItemInstance*(*Player$getSelectedItem)(Player*);
static int(*ItemInstance$getId)(ItemInstance*);
static BlockID (*BlockSource$getBlockID)(BlockSource*, int, int, int);
static int(*BlockSource$getData)(BlockSource*, int, int, int);
static void(*BlockSource$setBlockAndData)(BlockSource*, const BlockPos&, BlockID, unsigned char, int);
static void (*GuiData$displayClientMessage)(GuiData*, const std::string&);

GuiData* guiData = NULL;
BlockSource* now_region;

BlockPos pos1, pos2;
Vec3 min, max;

std::string set_cmd = "wait_msg";



std::vector<std::string> strSplit(const std::string s, char del)
{
	std::vector<std::string> tokens;
	std::string currentToken = "";

	int i = 0;
	while(s[i] != '\0') {
		if(s[i] != del) {
			currentToken += s[i];
		} else {
			tokens.push_back(currentToken);
			currentToken = "";
		}
		i++;
	}
	tokens.push_back(currentToken);
	return tokens;
}

void (*GuiData_tick)(GuiData*);
void _GuiData_tick(GuiData* _guiData) {
	if(!guiData)
		guiData = _guiData;

	GuiData_tick(_guiData);
}

void (*GuiData_displayChatMessage)(GuiData*, const std::string&, const std::string&);
void _GuiData_displayChatMessage(GuiData* self, const std::string& owner, const std::string& msg) {
	set_cmd = msg;

	min.x = std::min(pos1.x, pos2.x);
	max.x = std::max(pos1.x, pos2.x);
	min.y = std::min(pos1.y, pos2.y);
	max.y = std::max(pos1.y, pos2.y);
	min.z = std::min(pos1.z, pos2.z);
	max.z = std::max(pos1.z, pos2.z);

	std::vector<std::string> pars = strSplit(set_cmd, ' ');

	if(pars[0] == "$set") {
		std::vector<std::string> blockArgs = strSplit(pars[1], ':');
		int blockId = stoi(blockArgs[0]);
		int data = stoi(blockArgs[1]);

		for(int ix = min.x; ix <= max.x; ix++) {
			for(int iy = min.y; iy <= max.y; iy++) {
				for(int iz = min.z; iz <= max.z; iz++) {
					BlockSource$setBlockAndData(now_region, {ix, iy, iz}, blockId, data, 3);
				}
			}
		}
	}

	set_cmd = "wait_msg";
}

bool (*Item_useOn)(Item*, ItemInstance*, Player*, int, int, int, signed char, float, float, float);
bool _Item_useOn(Item* self, ItemInstance* inst, Player* player, int x, int y, int z, signed char side, float xx, float yy, float zz) {
	if(self == Item$mItems[271]) {
		pos1 = {x, y, z};

		char buf[50];
		sprintf(buf, "§cYou set pos1 at %d, %d, %d", pos1.x, pos1.y, pos1.z);
		GuiData$displayClientMessage(guiData, std::string(buf));
	}

	return Item_useOn(self, inst, player, x, y, z, side, xx, yy, zz);
}

bool (*GameMode_creativeDestroyBlock)(GameMode*, Player&, const BlockPos&, signed char);
bool _GameMode_creativeDestroyBlock(GameMode* self, Player& player, const BlockPos& pos, signed char side) {
	if(Player$getSelectedItem(&player)->item == Item$mItems[271]) {
		pos2 = pos;

		char buf[50];
		sprintf(buf, "§9You set pos2 at %d, %d, %d", pos2.x, pos2.y, pos2.z);
		GuiData$displayClientMessage(guiData, std::string(buf));

		return false;
	}

	return GameMode_creativeDestroyBlock(self, player, pos, side);
}

void (*Player_normalTick)(Player*);
void _Player_normalTick(Player* player) {
	now_region = player->region;

	Player_normalTick(player);
}

%ctor {
	MSHookFunction((void*)(0x100107fc4 + _dyld_get_image_vmaddr_slide(0)), (void*)&_GuiData_tick, (void**)&GuiData_tick);
	MSHookFunction((void*)(0x10010881c + _dyld_get_image_vmaddr_slide(0)), (void*)&_GuiData_displayChatMessage, (void**)&GuiData_displayChatMessage);

	MSHookFunction((void*)(0x100746be0 + _dyld_get_image_vmaddr_slide(0)), (void*)&_Item_useOn, (void**)&Item_useOn);

	MSHookFunction((void*)(0x100720638 + _dyld_get_image_vmaddr_slide(0)), (void*)&_GameMode_creativeDestroyBlock, (void**)&GameMode_creativeDestroyBlock);

	MSHookFunction((void*)(0x10070ec64 + _dyld_get_image_vmaddr_slide(0)), (void*)&_Player_normalTick, (void**)&Player_normalTick);


	Item$mItems = (Item**)(0x1012ae238 + _dyld_get_image_vmaddr_slide(0));

	GuiData$displayClientMessage = (void(*)(GuiData*, const std::string&))(0x100108794 + _dyld_get_image_vmaddr_slide(0));

	Player$getSelectedItem = (ItemInstance*(*)(Player*))(0x10070f5c4 + _dyld_get_image_vmaddr_slide(0));

	ItemInstance$getId = (int(*)(ItemInstance*))(0x10075700c + _dyld_get_image_vmaddr_slide(0));

	BlockSource$getBlockID = (BlockID(*)(BlockSource*, int, int, int))(0x10079c2d0 + _dyld_get_image_vmaddr_slide(0));
	BlockSource$getData = (int(*)(BlockSource*, int, int, int))(0x10079ddd0 + _dyld_get_image_vmaddr_slide(0));
	BlockSource$setBlockAndData = (void(*)(BlockSource*, const BlockPos&, BlockID, unsigned char, int))(0x10079bb6c + _dyld_get_image_vmaddr_slide(0));
}