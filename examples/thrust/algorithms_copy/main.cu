#include "copy.cuh"
#include "copy_n.cuh"
#include "gather.cuh"
#include "gather_if.cuh"
#include "scatter.cuh"
#include "scatter_if.cuh"

int main() {
  gather::demo();
  gather_if::demo();

  scatter::demo();
  scatter_if::demo();

  copy::demo();
  copy_n::demo();
  return 0;
}