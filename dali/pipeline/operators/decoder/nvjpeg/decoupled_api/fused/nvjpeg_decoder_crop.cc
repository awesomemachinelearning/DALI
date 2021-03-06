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

#include <vector>
#include "dali/pipeline/operators/decoder/nvjpeg/decoupled_api/fused/nvjpeg_decoder_crop.h"

namespace dali {

DALI_SCHEMA(nvJPEGDecoderCrop)
  .DocStr(R"code(Partially decode JPEG images using the nvJPEG library and a cropping window.
Output of the decoder is on the GPU and uses `HWC` ordering)code")
  .NumInput(1)
  .NumOutput(1)
  .AddParent("ImageDecoderCrop")
  .Deprecate("ImageDecoderCrop");

DALI_REGISTER_OPERATOR(nvJPEGDecoderCrop, nvJPEGDecoderCrop, Mixed);
DALI_REGISTER_OPERATOR(ImageDecoderCrop, nvJPEGDecoderCrop, Mixed);

}  // namespace dali
