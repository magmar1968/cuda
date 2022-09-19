#include "./parse_lib.cuh"

namespace prcr
{

    H bool cmdOptionExists(char** begin, char** end, const std::string& option)
    {
        return std::find(begin, end, option) != end;
    }

    H std::string getCmdOption(char ** begin, char ** end, const std::string & option)
    {
        char ** itr = std::find(begin, end, option);
        if (itr != end && ++itr != end)
        {
            return *itr;
        }
        return 0;
    }

    //file options 
    H bool fileOptionExist(std::string fileName, 
                           std::string option, 
                           std::string *_line)
    {
        std::fstream ifs(fileName, std::fstream::in);

        bool found = false;
        std::string * line = new std::string;
        std::string appo;
        if(!ifs.is_open())
        {
            std::cerr << "ERROR: unable to open the file input\n"
                      << "       please check the file name   \n";
            delete(line);
            exit(-1);
        }
        while(!ifs.bad() and !ifs.eof())
        {
            std::getline(ifs,*line);
            // eliminate line of comments and blank lines
            if(line->size() == 0)
                continue;
            
            if(line->find("!") != std::string::npos)
            {
                if(line->rfind("!")== 0)
                    continue;
                else{
                    line->resize(line->find("!"));
                }
            }

            if(!(line->rfind("#",0)==0))//basically a don't start with
                continue;

            //look for the option
            if(line->find(option) != std::string::npos)
            {
                found = true;
                *_line = *line;
                break;
            }
        }
        delete(line);
        return found;
    }




    __host__ bool
    ReadInputOption(std::string filename, 
                    Dev_opts * dev_opts,
                    Yc_args  * yc_args,
                    Vol_args * vol_args,
                    Schedule_args * schedule_args,
                    Eq_descr_args * eq_descr_args,
                    Eq_price_args * eq_price_args)
    {

        bool status = true;
        
        
        //dev options input
        status = status && fileGetOptionValue<bool>(filename,"CPU",&dev_opts->CPU);
        status = status && fileGetOptionValue<bool>(filename,"GPU",&dev_opts->GPU);
        if(dev_opts->CPU == false and dev_opts->GPU == false)
        {
            std::cerr << "INPUT ERROR: at least one between CPU and GPU must be set to true.\n"
                      << "             Please check your input file and retry.              \n";
            status =  false;
        }


        status = status && fileGetOptionValue<size_t>(filename, "N_blocks",  &dev_opts->N_blocks);
        status = status && fileGetOptionValue<size_t>(filename, "N_threads", &dev_opts->N_threads);

        //-----------------------------------------------------------------------------------------------------
        //yield curve options 
        status = status && fileGetOptionValue<bool>(filename, "yc_structured", &yc_args->structured);
        if(yc_args->structured == false) //the yc is flat
            status = status && fileGetOptionValue<double>(filename,"yc_rate", &yc_args->rate);
        else //structured yc 
        {
            std::vector<double> vec_rates,vec_times;
            status = status && fileGetOptionVectorVal<double>(filename, "yc_rates", &vec_rates);
            status = status && fileGetOptionVectorVal<double>(filename, "yc_times", &vec_times);
            if(vec_rates.size() != vec_times.size())
            {
                std::cerr << "INPUT ERROR: the size of times's and rates's array of the yield must\n"
                          << "             be equal. Please check your input file and retry.      \n";
                status = false;
            }
            else
            {
                yc_args->dim = vec_rates.size();
                double * rates, * times = new double[yc_args->dim];
                for(int i = 0; i < yc_args->dim; ++i)
                  {  rates[i]=vec_rates[i]; times[i] = vec_times[i];}
                yc_args->rates = rates;
                yc_args->times = times; 
            }
        }
        
        //-----------------------------------------------------------------------------------------------------
        //volatility
        status = status && fileGetOptionValue<double>(filename, "volatility", &vol_args->vol);


        //-----------------------------------------------------------------------------------------------------
        //equity description arguments
        std::string isin_code,name,currency;
        status = status && fileGetOptionValue<std::string>(filename,"eq_descr_isin_code",&isin_code);
        status = status && fileGetOptionValue<std::string>(filename,"eq_descr_name", &name);
        status = status && fileGetOptionValue<std::string>(filename,"eq_descr_currency",&currency);
        status = status && fileGetOptionValue<double>(filename,"eq_secr_dy",&eq_descr_args->dividend_yield);

        strcpy(eq_descr_args->isin_code,isin_code.c_str());
        strcpy(eq_descr_args->name,name.c_str());
        strcpy(eq_descr_args->currency,currency.c_str());

        //-----------------------------------------------------------------------------------------------------
        //equity price arguments 
        status = status && fileGetOptionValue<double>(filename, "eq_price_time",  &eq_price_args->time);
        status = status && fileGetOptionValue<double>(filename, "eq_price_price", &eq_price_args->price);


        return status;
    }



























}


