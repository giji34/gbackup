#include "minecraft-file.hpp"
#include "hwm/task/task_queue.hpp"

using namespace std;
using namespace mcfile;

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("merge-chunks-to-regions: Merge compressed chunk files (c.{x}.{z}.nbt.z) to region files (r.{x}.{z}.mca) files. Region files will be dumped to current directory\n");
        printf("Usage:\n");
        printf("    merge-chunks-to-regions [directory where chunks files are stored]\n");
        return 1;
    }

    hwm::task_queue q(thread::hardware_concurrency());
    vector<future<void>> futures;

    string chunkDir(argv[1]);
    Region::IterateRegionForCompressedNbtFiles(chunkDir, [&q, &futures](int regionX, int regionZ, string const& chunkDir) -> bool {
        futures.emplace_back(q.enqueue([](int regionX, int regionZ, string const& chunkDir) {
            Region::ConcatCompressedNbt(regionX, regionZ, chunkDir, Region::GetDefaultRegionFileName(regionX, regionZ));
        }, regionX, regionZ, chunkDir));
        return true;
    });

    for (auto& f : futures) {
        f.get();
    }

    return 0;
}
