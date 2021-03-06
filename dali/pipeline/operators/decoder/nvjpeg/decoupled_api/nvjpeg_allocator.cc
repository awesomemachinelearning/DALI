// Copyright (c) 2019, NVIDIA CORPORATION. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "dali/pipeline/operators/decoder/nvjpeg/decoupled_api/nvjpeg_allocator.h"

#include <unordered_map>

namespace dali {

namespace memory {

using CPA = ChunkPinnedAllocator;
std::vector<CPA::Chunk> CPA::chunks_;
size_t CPA::element_size_hint_;
std::unordered_map<void*, CPA::ChunkIdxBlockIdx> CPA::allocated_buffers_;
size_t CPA::counter_ = 0;
std::mutex CPA::mutex_;

}  // namespace memory

}  // namespace dali
