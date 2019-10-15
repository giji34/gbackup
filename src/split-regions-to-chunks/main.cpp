#include "minecraft-file.hpp"

using namespace std;
using namespace mcfile;

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("split-regions-to-chunks: split *.mca to per-chunk, compressed files to current directory\n");
        printf("Usage:\n");
        printf("    split-regions-to-chunks [world directory containing 'region' directory]\n");
        printf("Decompress to nbt:\n");
        printf("    pigz -z -d < c.0.0.nbt.z > c.0.0.nbt\n");
        return 1;
    }
    std::string worldDir = argv[1];
    
    World w(worldDir);
    auto region = w.region(0, 0);
    if (!region) {
        return 1;
    }
    w.eachRegions([](auto const& region) {
        region->exportAllToCompressedNbt("./");
    });
    return 0;
}
