#ifndef __PROCESS_EQ_BINOMIAL__
#define __PROCESS_EQ_BINOMIAL__

#include "../process.cuh"
#include "../../support_lib/myDouble_lib/myudouble.cuh"
#include "../../equity_lib/equity_prices.cuh"

// cuda macro

namespace prcr
{
#define H __host__
#define D __device__
#define HD __host__ __device__ 
  
  class Process_eq_binomial : public Process
  {
    private:
    
    public:
      HD Process_eq_binomial(){};
      HD Process_eq_binomial(rnd::MyRandom * gnr);
      HD virtual ~Process_eq_binomial(){};
      //functions
      HD double Get_new_eq_price(
                Equity_description * eq_descr,
                double eq_price,
                double w,
                double delta_t);
      
      

    //functions 
    private:
      HD double compute_eq_price_exact(
                      double eq_price,
                      double r,
                      double div_yield,
                      double delta_t,
                      double w,
                      double sigma);
    
  };

} // namespace prcr



#endif
