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

#ifndef DALI_KERNELS_IMGPROC_WARP_WARP_SETUP_CUH_
#define DALI_KERNELS_IMGPROC_WARP_WARP_SETUP_CUH_

#include <vector>
#include <utility>
#include "dali/kernels/kernel.h"
#include "dali/kernels/common/block_setup.h"
#include "dali/core/geom/vec.h"

namespace dali {
namespace kernels {
namespace warp {

template <int ndim, typename OutputType, typename InputType>
struct SampleDesc {
  OutputType *__restrict__ output;
  const InputType *__restrict__ input;
  ivec<ndim> out_size, out_strides, in_size, in_strides;
  int channels;
  DALIInterpType interp;
};


template <int ndim, typename OutputType, typename InputType>
class WarpSetup : public BlockSetup<ndim, ndim> {
  static_assert(ndim == 2 || ndim == 3,
    "Warping is defined only for 2D and 3D data with interleaved channels");

 public:
  using Base = BlockSetup<ndim, ndim>;
  using Base::tensor_ndim;
  using Base::Blocks;
  using Base::IsUniformSize;
  using Base::SetupBlocks;
  using Base::shape2size;
  using SampleDesc = warp::SampleDesc<ndim, OutputType, InputType>;
  using BlockDesc = kernels::BlockDesc<ndim>;

  KernelRequirements Setup(const TensorListShape<tensor_ndim> &output_shape,
                           bool force_variable_size = false) {
    SetupBlocks(output_shape, force_variable_size);

    KernelRequirements req = {};
    ScratchpadEstimator se;
    se.add<SampleDesc>(AllocType::GPU, output_shape.num_samples());
    se.add<BlockDesc>(AllocType::GPU, Blocks().size());
    req.output_shapes = { output_shape };
    req.scratch_sizes = se.sizes;
    return req;
  }

  template <typename Backend>
  void PrepareSamples(const OutList<Backend, OutputType, tensor_ndim> &out,
                      const InList<Backend, InputType, tensor_ndim> &in,
                      span<const DALIInterpType> interp) {
    assert(out.num_samples() == in.num_samples());
    assert(interp.size() == in.num_samples() || interp.size() == 1);
    samples_.resize(in.num_samples());
    for (int i = 0; i < in.num_samples(); i++) {
      SampleDesc &sample = samples_[i];
      sample.input = in.tensor_data(i);
      sample.output = out.tensor_data(i);
      auto out_shape = out.tensor_shape(i);
      auto in_shape = in.tensor_shape(i);
      int channels = out_shape[ndim];
      sample.channels = channels;
      sample.out_size = shape2size(out_shape);
      sample.in_size = shape2size(in_shape);

      sample.out_strides.x = channels;
      sample.out_strides.y = sample.out_size.x * sample.out_strides.x;

      sample.in_strides.x = channels;
      sample.in_strides.y = sample.in_size.x * sample.in_strides.x;

      sample.interp = interp[interp.size() == 1 ? 0 : i];
    }
  }

  span<const SampleDesc> Samples() const { return make_span(samples_); }

 private:
  std::vector<SampleDesc> samples_;
};

}  // namespace warp
}  // namespace kernels
}  // namespace dali

#endif  // DALI_KERNELS_IMGPROC_WARP_WARP_SETUP_CUH_
