#pragma once

#include "xmol/trajectory/Trajectory.h"

#include <fstream>
#include <memory>

namespace xmol {
namespace pdb {

class PdbReader;
class basic_PdbRecords;

class PdbFile : public xmol::trajectory::TrajectoryPortion {
public:
  PdbFile(const PdbFile& rhs) : PdbFile(rhs.m_filename){};
  explicit PdbFile(const std::string& filename);
  ~PdbFile() override = default;
  std::unique_ptr<TrajectoryPortion> get_copy() const override;
  void set_coordinates(xmol::polymer::frameIndex_t frameIndex,
                       const xmol::polymer::AtomSelection& atoms, const std::vector<int>& update_list) override;
  xmol::polymer::frameIndex_t n_frames() const override;
  xmol::polymer::atomIndex_t n_atoms_per_frame() const override;
  bool match(const xmol::polymer::AtomSelection& atoms) const override;
  void close() override;

  xmol::polymer::Frame get_frame(const basic_PdbRecords& pdbRecords);
  xmol::polymer::Frame get_frame();
  xmol::polymer::Frame get_frame(int n);

private:
  std::string m_filename;
  std::unique_ptr<std::ifstream> m_stream;
  std::unique_ptr<PdbReader> m_reader;
};
}
}

