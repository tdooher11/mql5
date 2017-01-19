//+------------------------------------------------------------------+
//|                                                   SampleMQL5.mq5 |
//|                                             Copyright KlimMalgin |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "KlimMalgin"
#property link      ""
#property version   "1.00"


int MA1 = 0,            // Declaring variable to store fast MA handle
    MA2 = 0,            // Declaring variable to store slow MA handle
    SAR = 0;            // Declaring variable to store SAR handle
    
MqlParam params[];      // Array for storing indicators parameters

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
/*************************************************/
/*   1st method of calling indicators            */
/*************************************************

   // Setting the params size equal to number of called indicator parameters
   ArrayResize(params,4);

//*    Calling indicators    *
//***************************
   // Setting the period of fast MA
   params[0].type         =TYPE_INT;
   params[0].integer_value=5;
   // Offset
   params[1].type         =TYPE_INT;
   params[1].integer_value=0;
   // Calculation method: simple averaging
   params[2].type         =TYPE_INT;
   params[2].integer_value=MODE_SMA;
   // Price type for calculation: the Close prices
   params[3].type         =TYPE_INT;
   params[3].integer_value=PRICE_CLOSE;
   
   MA1 = IndicatorCreate(Symbol(), 0, IND_MA, 4, params);
   
   // Setting the period of slow MA
   params[0].type         =TYPE_INT;
   params[0].integer_value=21;
   // Offset
   params[1].type         =TYPE_INT;
   params[1].integer_value=0;
   // Calculation method: simple averaging
   params[2].type         =TYPE_INT;
   params[2].integer_value=MODE_SMA;
   // Price type for calculation: the Close prices
   params[3].type         =TYPE_INT;
   params[3].integer_value=PRICE_CLOSE;
   
   MA2 = IndicatorCreate(Symbol(), 0, IND_MA, 4, params);
   
   
   // Changing array size to store the SAR indicator parameters
   ArrayResize(params,2);
   // Step
   params[0].type         =TYPE_DOUBLE;
   params[0].double_value = 0.02;
   // Maximum
   params[1].type         =TYPE_DOUBLE;
   params[1].double_value = 0.2;
   
   SAR = IndicatorCreate(Symbol(), 0, IND_SAR, 2, params);
   
   
/*************************************************/
/*   2nd method of calling indicators            */
/*************************************************/
   ResetLastError();
   MA1 = iCustom(NULL,0,"Examples\Custom Moving Average",
                          5,          // Period
                          0,          // Offset
                          MODE_SMA,   // Calculation method
                          PRICE_CLOSE // Calculating on Close prices
                 );
   Print("MA1 =",MA1,"  error =",GetLastError());
   ResetLastError();
   MA2 = iCustom(NULL,0,"Examples\Custom Moving Average",
                          21,         // Period
                          0,          // Offset
                          MODE_SMA,   // Calculation method
                          PRICE_CLOSE // Calculating on Close prices
                 );
   Print("MA2 =",MA2,"  error =",GetLastError());
   ResetLastError();

   SAR = iCustom(NULL,0,"Examples\ParabolicSAR",
                          0.02,        // Step
                          0.2          // Maximum
                 );
   Print("SAR =",SAR,"  error =",GetLastError());
   

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

// Dynamic arrays to store indicators values
double _ma1[],
       _ma2[],
       _sar[];

// Setting the indexing in arrays the same as in timeseries, i.e. array element with zero
// index will store the values of the last bar, with 1th index - the last but one, etc.
   ArraySetAsSeries(_ma1, true);
   ArraySetAsSeries(_ma2, true);
   ArraySetAsSeries(_sar, true);

// Using indicators handles, let's copy the values of indicator
// buffers to arrays, specially prepared for this purpose
   if (CopyBuffer(MA1,0,0,20,_ma1) < 0){Print("CopyBufferMA1 error =",GetLastError());}
   if (CopyBuffer(MA2,0,0,20,_ma2) < 0){Print("CopyBufferMA2 error =",GetLastError());}
   if (CopyBuffer(SAR,0,0,20,_sar) < 0){Print("CopyBufferSAR error =",GetLastError());}

//---
  }
//+------------------------------------------------------------------+