#include "minecraft-file.hpp"
#include "hwm/task/task_queue.hpp"

using namespace std;
using namespace mcfile;

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
    vector<future<void>> futures;

    for (int i = 1; i < argc; i++) {
        string item = argv[i];
        fs::path p = item;
        error_code ec;
        if (fs::is_directory(p, ec)) {
            World w(item);
            w.eachRegions([&q, &futures](shared_ptr<Region> const& region) {
                futures.emplace_back(q.enqueue([](shared_ptr<Region> const& region) {
                    region->exportAllToCompressedNbt("./");
                }, region));
                return true;
            });
        } else if (fs::is_regular_file(p, ec)) {
            auto region = Region::MakeRegion(item);
            if (!region) {
                continue;
            }
            futures.emplace_back(q.enqueue([](std::shared_ptr<Region> const& r) {
                r->exportAllToCompressedNbt("./");
            }, region));
        }
    }

    for (auto& f : futures) {
        f.get();
    }

    return 0;
}
