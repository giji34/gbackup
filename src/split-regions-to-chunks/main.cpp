#include "minecraft-file.hpp"
#include "hwm/task/task_queue.hpp"

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

    hwm::task_queue q(thread::hardware_concurrency());
    vector<future<void>> futures;

    w.eachRegions([&q, &futures](auto const& region) {
        futures.emplace_back(q.enqueue([](auto const& region) {
            region->exportAllToCompressedNbt("./");
        }, region));
    });

    for (auto& f : futures) {
        f.get();
    }

    return 0;
}
