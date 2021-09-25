#include "minecraft-file.hpp"
#include "hwm/task/task_queue.hpp"

using namespace std;
using namespace mcfile;
using namespace mcfile::je;

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("split-regions-to-chunks: split *.mca to per-chunk, compressed files to current directory\n");
        printf("Usage:\n");
        printf("    split-regions-to-chunks [mca file or world directory containing 'region' directory]\n");
        printf("Decompress to nbt:\n");
        printf("    pigz -z -d < c.0.0.nbt.z > c.0.0.nbt\n");
        return 1;
    }

    namespace fs = std::filesystem;

    hwm::task_queue q(thread::hardware_concurrency());

    for (int i = 1; i < argc; i++) {
        string item = argv[i];
        fs::path p = item;
        error_code ec;
        if (fs::is_regular_file(p, ec)) {
            auto region = Region::MakeRegion(p);
            if (!region) {
                continue;
            }
            vector<future<void>> futures;
            for (int cx = region->minChunkX(); cx <= region->maxChunkX(); cx++) {
                for (int cz = region->minChunkZ(); cz <= region->maxChunkZ(); cz++) {
                    futures.emplace_back(q.enqueue([](std::shared_ptr<Region> const& region, int cx, int cz) {
                        fs::path outPath(Region::GetDefaultCompressedChunkNbtFileName(cx, cz));
                        region->exportToZopfliCompressedNbt(cx, cz, outPath);
                    }, region, cx, cz));
                }
            }
            for (auto& f : futures) {
                f.get();
            }
        }
    }

    return 0;
}
