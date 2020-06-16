#import "../substrate.h"
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <initializer_list>
#import <vector>
#import <map>
#import <mach-o/dyld.h>
#import <string>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <initializer_list>
#import <vector>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <iostream>
#import <stdio.h>
#include <sstream>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <string.h>
#include <algorithm>
#include <fstream>
#include <ifaddrs.h>
#include <stdint.h>
#include <dlfcn.h>

typedef struct {
	char filler[64];
	uintptr_t* level;
	char filler2[104];
	uintptr_t* region;
} Entity;

struct Player :public Entity {
	char filler[4400];

	uintptr_t* inventory;
};

struct BlockID {
	unsigned char value;

	BlockID() {
		this->value = 1;
	}

	BlockID(unsigned char val) {
		this->value = val;
	}

	BlockID(BlockID const& other) {
		this->value = other.value;
	}

	bool operator==(char v) {
		return this->value == v;
	}

	bool operator==(int v) {
		return this->value == v;
	}

	bool operator==(BlockID v) {
		return this->value == v.value;
	}

	BlockID& operator=(const unsigned char& v) {
		this->value = v;
		return *this;
	}

	operator unsigned char() {
		return this->value;
	}
};

typedef struct {
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
} Item;

typedef struct {
	uint8_t count;
	uint16_t aux;
	uintptr_t* tag;
	Item* item;
	uintptr_t* block;
	int idk[3];
} ItemInstance;

typedef struct {
	int x, y, z;
} BlockPos;

static Item** Item$mItems;

static ItemInstance*(*Player$getSelectedItem)(Player*);

static int(*ItemInstance$getId)(void*);

static BlockID (*BlockSource$getBlockID)(uintptr_t*, int, int, int);

static int(*BlockSource$getData)(uintptr_t*, int, int, int);

static void(*BlockSource$setBlock)(uintptr_t*, int, int, int, BlockID, int);

uintptr_t* guiData = NULL;

int pos1X = 0, pos1Y = 0, pos1Z = 0;
int pos2X = 0, pos2Y = 0, pos2Z = 0;

int minX = 0, minY = 0, minZ = 0;
int maxX = 0, maxY = 0, maxZ = 0;

std::string set_cmd = "wait_msg";

uintptr_t* now_region;

void (*GuiData_displayClientMessage)(uintptr_t*, const std::string&);
void _GuiData_displayClientMessage(const std::string&);

void (*GuiData_displayChatMessage)(uintptr_t*, const std::string&, const std::string&);
void _GuiData_displayChatMessage(const std::string&, const std::string&);

void (*GuiData_tick)(uintptr_t*);
void _GuiData_tick(uintptr_t* _guiData) {
	guiData = _guiData;

	GuiData_tick(_guiData);
}

void _GuiData_displayChatMessage(const std::string& owner, const std::string& msg) {
	if(guiData != NULL) {
		GuiData_displayChatMessage(guiData, owner, msg);
	}
	set_cmd = msg;

	minX = std::min(pos1X, pos2X);
	maxX = std::max(pos1X, pos2X);
	minY = std::min(pos1Y, pos2Y);
	maxY = std::max(pos1Y, pos2Y);
	minZ = std::min(pos1Z, pos2Z);
	maxZ = std::max(pos1Z, pos2Z);

	for(int i = 0; i <= 255; i++) {
		for(int j = 0; j <= 15; j++) {
			if(set_cmd == "//set " + std::to_string(i) + ":" + std::to_string(j)) {

				unsigned char block_id = i;

				for(int ix = minX; ix <= maxX; ix++) {
					for(int iy = minY; iy <= maxY; iy++) {
						for(int iz = minZ; iz <= minZ; iz++) {
							BlockSource$setBlock(now_region, ix, iy, iz, block_id, j);
						}
					}
				}
			}
		}
	}

	set_cmd = "wait_msg";
}

void _GuiData_displayClientMessage(const std::string& msg) {
	if(guiData != NULL) {
		GuiData_displayClientMessage(guiData, msg);
	}
}

bool (*Item_useOn)(Item*, uintptr_t*, Player*, int, int, int, signed char, float, float, float);
bool _Item_useOn(Item* self, uintptr_t* inst, Player* player, int x, int y, int z, signed char side, float xx, float yy, float zz) {
	if(self == Item$mItems[271]) {
		pos1X = x;
		pos1Y = y;
		pos1Z = z;

		GuiData_displayClientMessage(guiData, "§9You got a pos1");
	}

	return Item_useOn(self, inst, player, x, y, z, side, xx, yy, zz);
}

bool (*GameMode_creativeDestroyBlock)(uintptr_t*, Player&, BlockPos, signed char);
bool _GameMode_creativeDestroyBlock(uintptr_t* self, Player& player, BlockPos pos, signed char side) {
	if(Player$getSelectedItem(&player)->item == Item$mItems[271]) {
		pos2X = pos.x;
		pos2Y = pos.y;
		pos2Z = pos.z;

		GuiData_displayClientMessage(guiData, "§cYou got a pos2");

		return false;
	}

	return GameMode_creativeDestroyBlock(self, player, pos, side);
}

void (*Player_normalTick)(Player*);
void _Player_normalTick(Player* player) {
	Player_normalTick(player);

	now_region = player->region;
}

%ctor {
	MSHookFunction((void*)(0x100107fc4 + _dyld_get_image_vmaddr_slide(0)), (void*)&_GuiData_tick, (void**)&GuiData_tick);
	MSHookFunction((void*)(0x10010881c + _dyld_get_image_vmaddr_slide(0)), (void*)&_GuiData_displayChatMessage, (void**)&GuiData_displayChatMessage);
	MSHookFunction((void*)(0x100108794 + _dyld_get_image_vmaddr_slide(0)), (void*)&_GuiData_displayClientMessage, (void**)&GuiData_displayClientMessage);

	MSHookFunction((void*)(0x100746be0 + _dyld_get_image_vmaddr_slide(0)), (void*)&_Item_useOn, (void**)&Item_useOn);

	MSHookFunction((void*)(0x100720638 + _dyld_get_image_vmaddr_slide(0)), (void*)&_GameMode_creativeDestroyBlock, (void**)&GameMode_creativeDestroyBlock);

	MSHookFunction((void*)(0x10070ec64 + _dyld_get_image_vmaddr_slide(0)), (void*)&_Player_normalTick, (void**)&Player_normalTick);

	Item$mItems = (Item**)(0x1012ae238 + _dyld_get_image_vmaddr_slide(0));

	Player$getSelectedItem = (ItemInstance*(*)(Player*))(0x10070f5c4 + _dyld_get_image_vmaddr_slide(0));

	ItemInstance$getId = (int(*)(void*))(0x10075700c + _dyld_get_image_vmaddr_slide(0));

	BlockSource$getBlockID = (BlockID(*)(uintptr_t*, int, int, int))(0x10079c2d0 + _dyld_get_image_vmaddr_slide(0));

	BlockSource$getData = (int(*)(uintptr_t*, int, int, int))(0x10079ddd0 + _dyld_get_image_vmaddr_slide(0));

	BlockSource$setBlock = (void(*)(uintptr_t*, int, int, int, BlockID, int))(0x10079b294 + _dyld_get_image_vmaddr_slide(0));
}