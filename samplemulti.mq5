//+---------------------------------------------------------------------+
//|                                                2multi.mq5           |
//|                                       Author:   Maxim Khrolenko      |
//|                                       E-mail:  forevex@mail.ru      |
//+---------------------------------------------------------------------+
#property copyright "Maxim Khrolenko"
#property link      "forevex@mail.ru"

//--- Include standard libraries
#include <Trade\AccountInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>

//--- Number of symbols for each strategy
#define Strategy_A 2
#define Strategy_B 2

//------------------- External parameters of strategy A
input string          Data_for_Strategy_A="Strategy A -----------------------";
//--- Symbol 0
input string          Symbol_A0      = "EURUSD";  // Symbol
input bool            IsTrade_A0     = true;      // Permission for trading
//--- Bollinger Bands (BB) parameters
input ENUM_TIMEFRAMES Period_A0      = PERIOD_H1; // BB period
input uint            BBPeriod_A0    = 12;        // Period for calculation of the moving average of BB
input int             BBShift_A0     = 0;         // Horizontal shift of BB
input double          BBDeviation_A0 = 2.2;       // Number of standard deviations of BB

//--- Symbol 1
input string          Symbol_A1      = "GBPUSD";  // Symbol
input bool            IsTrade_A1     = true;      // Permission for trading
//--- Bollinger Bands (BB) parameters
input ENUM_TIMEFRAMES Period_A1      = PERIOD_H4; // BB period
input uint            BBPeriod_A1    = 17;        // Period for calculation of the moving average of BB
input int             BBShift_A1     = 0;         // Horizontal shift of BB
input double          BBDeviation_A1 = 1.4;       // Number of standard deviations of BB

//--- General parameters of strategy A
input double          DealOfFreeMargin_A = 1.0;   // Percent of free margin for a deal
input uint            MagicNumber_A      = 555;   // Magic number
input uint            Slippage_A         = 100;   // Permissible slippage for a deal

//------------------- External parameters of strategy B
input string          Data_for_Strategy_B="Strategy B -----------------------";
//--- Symbol 0
input string          Symbol_B0      = "AUDUSD";  // Symbol
input bool            IsTrade_B0     = true;      // Permission for trading
input uint            FullBarSize_B0 = 100;       // Bar size (points, from high to low)
input uint            BodyBarSize_B0 = 50;        // Bar size (points, from close to open)
input uint            StopLoss_B0    = 500;       // Stop Loss (points)
input uint            TakeProfit_B0  = 300;       // Take Profit (points)
input ENUM_TIMEFRAMES TFcode_B0      = PERIOD_D1; // Time frame

//--- Symbol 1
input string          Symbol_B1      = "EURJPY";  // Symbol
input bool            IsTrade_B1     = true;      // Permission for trading
input uint            FullBarSize_B1 = 100;       // Bar size (points, from high to low)
input uint            BodyBarSize_B1 = 50;        // Bar size (points, from close to open)
input uint            StopLoss_B1    = 200;       // Stop Loss (points)
input uint            TakeProfit_B1  = 450;       // Take Profit (points)
input ENUM_TIMEFRAMES TFcode_B1      = PERIOD_D1; // Time frame

//--- General parameters of strategy B
input double          DealOfFreeMargin_B = 2.0;   // Percent of free margin for a deal
input uint            MagicNumber_B      = 777;   // Magic number
input uint            Slippage_B         = 100;   // Permissible slippage for a deal

//------------- Set variables of strategy A -----
//--- Arrays for external parameters
string          Symbol_A[Strategy_A];
bool            IsTrade_A[Strategy_A];
ENUM_TIMEFRAMES Period_A[Strategy_A];
int             BBPeriod_A[Strategy_A];
int             BBShift_A[Strategy_A];
double          BBDeviation_A[Strategy_A];
//--- Arrays for global variables
double          MinLot_A[Strategy_A],MaxLot_A[Strategy_A];
double          Point_A[Strategy_A],ContractSize_A[Strategy_A];
uint            DealNumber_A[Strategy_A];
datetime        Locked_bar_time_A[Strategy_A],time_arr_A[];
//--- Indicator handles
int             BB_handle_high_A[Strategy_A];
int             BB_handle_low_A[Strategy_A];
//--- Arrays for indicator values
double          BB_upper_band_high[],BB_lower_band_high[];
double          BB_upper_band_low[],BB_lower_band_low[];
//--- Class
CTrade          Trade_A;

//------------- Set variables of strategy B -----
//--- Arrays for external parameters
string          Symbol_B[Strategy_B];
bool            IsTrade_B[Strategy_B];
uint            FullBarSize_B[Strategy_B];
uint            BodyBarSize_B[Strategy_B];
uint            StopLoss_B[Strategy_B];
uint            TakeProfit_B[Strategy_B];
ENUM_TIMEFRAMES TFcode_B[Strategy_B];
//--- Arrays for global variables
double          MinLot_B[Strategy_B],MaxLot_B[Strategy_B];
double          StopLossDiff_B[Strategy_B];
int             Digits_B[Strategy_B];
double          Point_B[Strategy_B],ContractSize_B[Strategy_B];
datetime        Locked_bar_time_B[Strategy_B],time_arr_B[];
//--- Price arrays
double          low_arr[],high_arr[],open_arr[],close_arr[];
//--- Class
CTrade          Trade_B;

//--- Set global variables for all strategies
long            Leverage;
//--- Classes
CAccountInfo    AccountInfo;
CPositionInfo   PositionInfo;
CSymbolInfo     SymbolInfo;
//---===================== The OnInit function =======================================================
int OnInit()
  {
//--- Set event generation frequency
   EventSetTimer(1); // 1 second

//--- Get the leverage for the account
   Leverage=AccountInfo.Leverage();

//--- Checks and actions associated with strategy A -------------
//--- Copy external variables to arrays
   Symbol_A[0]=Symbol_A0;
   Symbol_A[1]=Symbol_A1;

   IsTrade_A[0]=IsTrade_A0;
   IsTrade_A[1]=IsTrade_A1;

   Period_A[0]=Period_A0;
   Period_A[1]=Period_A1;

   BBPeriod_A[0]=(int)BBPeriod_A0;
   BBPeriod_A[1]=(int)BBPeriod_A1;

   BBShift_A[0]=BBShift_A0;
   BBShift_A[1]=BBShift_A1;

   BBDeviation_A[0]=BBDeviation_A0;
   BBDeviation_A[1]=BBDeviation_A1;

//--- Check for the symbol in the Market Watch
   for(int i=0; i<Strategy_A; i++)
     {
      if(IsTrade_A[i]==false) continue;
      if((Symbol_A[i])==false)
        {
         Print(Symbol_A[i]," could not be found on the server!");
         ExpertRemove();
        }
     }

//--- Check whether the symbol is used more than once
   if(Strategy_A>1)
     {
      for(int i=0; i<Strategy_A-1; i++)
        {
         if(IsTrade_A[i]==false) continue;
         for(int j=i+1; j<Strategy_A; j++)
           {
            if(IsTrade_A[j]==false) continue;
            if(Symbol_A[i]==Symbol_A[j])
              {
               Print(Symbol_A[i]," is used more than once!");
               ExpertRemove();
              }
           }
        }
     }

//--- General actions
   for(int i=0; i<Strategy_A; i++)
     {
      if(IsTrade_A[i]==false) continue;

      //--- Check for errors in input parameters
      if(BBDeviation_A[i]<=0.0)
        {
         Print("The standard deviation of Bollinger Bands for ",Symbol_A[i]," must be more than 0.");
         ExpertRemove();
        }

      //--- Set indicator handles
      //--- based on High price
      BB_handle_high_A[i]=iBands(Symbol_A[i],Period_A[i],BBPeriod_A[i],BBShift_A[i],BBDeviation_A[i],
                                 PRICE_HIGH);
      if(BB_handle_high_A[i]<0)
        {
         Print("Failed to create a handle for Bollinger Bands based on High prices for ",Symbol_A[i]," . Handle=",INVALID_HANDLE,
               "\n Error=",GetLastError());
         ExpertRemove();
        }
      //--- based on Low price
      BB_handle_low_A[i]=iBands(Symbol_A[i],Period_A[i],BBPeriod_A[i],BBShift_A[i],BBDeviation_A[i],
                                PRICE_LOW);
      if(BB_handle_low_A[i]<0)
        {
         Print("Failed to create a handle for Bollinger Bands based on Low prices for ",Symbol_A[i]," . Handle=",INVALID_HANDLE,
               "\n Error=",GetLastError());
         ExpertRemove();
        }

      //--- Calculate data for the Lot
      //--- set the name of the symbol for which the information will be obtained
      SymbolInfo.Name(Symbol_A[i]);
      //--- minimum and maximum volume size in trading operations
      MinLot_A[i]=SymbolInfo.LotsMin();
      MaxLot_A[i]=SymbolInfo.LotsMax();
      //--- point value
      Point_A[i]=SymbolInfo.Point();
      //--- contract size
      ContractSize_A[i]=SymbolInfo.ContractSize();

      //--- Set some additional parameters
      DealNumber_A[i]=0;
      Locked_bar_time_A[i]=0;
     }

//--- Set parameters for trading operations
//--- set the magic number
   Trade_A.SetExpertMagicNumber(MagicNumber_A);
//--- set the permissible slippage in points upon deal execution
   Trade_A.SetDeviationInPoints(Slippage_A);
//--- order filling mode, use the mode that is allowed by the server
   Trade_A.SetTypeFilling(ORDER_FILLING_RETURN);
//--- logging mode, it is advisable not to call this method as the class will set the optimal mode by itself
   Trade_A.LogLevel(1);
//--- the function to be used for trading: true - OrderSendAsync(), false - OrderSend()
   Trade_A.SetAsyncMode(true);

//--- Checks and actions associated with strategy B -------------
//--- Copy external variables to arrays
   Symbol_B[0]=Symbol_B0;
   Symbol_B[1]=Symbol_B1;

   IsTrade_B[0]=IsTrade_B0;
   IsTrade_B[1]=IsTrade_B1;

   FullBarSize_B[0]=FullBarSize_B0;
   FullBarSize_B[1]=FullBarSize_B1;

   BodyBarSize_B[0]=BodyBarSize_B0;
   BodyBarSize_B[1]=BodyBarSize_B1;

   StopLoss_B[0]=StopLoss_B0;
   StopLoss_B[1]=StopLoss_B1;

   TakeProfit_B[0]=TakeProfit_B0;
   TakeProfit_B[1]=TakeProfit_B1;

   TFcode_B[0]=TFcode_B0;
   TFcode_B[1]=TFcode_B1;

//--- Check for the symbol in the Market Watch
   for(int i=0; i<Strategy_B; i++)
     {
      if(IsTrade_B[i]==false) continue;
      if(IsSymbolInMarketWatch(Symbol_B[i])==false)
        {
         Print(Symbol_B[i]," could not be found on the server!");
         ExpertRemove();
        }
     }
//--- Check whether the symbol is used more than once
   if(Strategy_B>1)
     {
      for(int i=0; i<Strategy_B-1; i++)
        {
         if(IsTrade_B[i]==false) continue;
         for(int j=i+1; j<Strategy_B; j++)
           {
            if(IsTrade_B[j]==false) continue;
            if(Symbol_B[i]==Symbol_B[j])
              {
               Print(Symbol_B[i]," is used more than once!");
               ExpertRemove();
              }
           }
        }
     }
//--- Calculate data for the Lot
   for(int i=0; i<Strategy_B; i++)
     {
      if(IsTrade_B[i]==false) continue;

      //--- set the name of the symbol for which the information will be obtained
      SymbolInfo.Name(Symbol_B[i]);
      //--- minimum and maximum volume size in trading operations
      MinLot_B[i]=SymbolInfo.LotsMin();
      MaxLot_B[i]=SymbolInfo.LotsMax();
      //--- number of decimal places
      Digits_B[i]=SymbolInfo.Digits();
      //--- point value
      Point_B[i]=SymbolInfo.Point();
      //--- contract size
      ContractSize_B[i]=SymbolInfo.ContractSize();

      //--- Set some additional parameters
      Locked_bar_time_B[i]=0;
     }

//--- Set parameters for trading operations
//--- set the magic number
   Trade_B.SetExpertMagicNumber(MagicNumber_B);
//--- set the permissible slippage in points upon deal execution
   Trade_B.SetDeviationInPoints(Slippage_B);
//--- order filling mode, use the mode that is allowed by the server
   Trade_B.SetTypeFilling(ORDER_FILLING_RETURN);
//--- logging mode, it is advisable not to call this method as the class will set the optimal mode by itself
   Trade_B.LogLevel(1);
//--- the function to be used for trading: true - OrderSendAsync(), false - OrderSend()
   Trade_B.SetAsyncMode(true); 

//--- Check whether one and the same symbol is used in several strategies
   for(int i=0; i<Strategy_A; i++)
     {
      if(IsTrade_A[i]==false) continue;
      for(int j=0; j<Strategy_B; j++)
        {
         if(IsTrade_B[j]==false) continue;
         if(Symbol_A[i]==Symbol_B[j])
           {
            Print(Symbol_A[i]," is used in several strategies!");
            ExpertRemove();
           }
        }
     }

   return(0);
  }
//-===================== The OnTimer function ======================================================
/*void OnTimer()
  {
//--- Check if the terminal is connected to the trade server
   if(TerminalInfoInteger(TERMINAL_CONNECTED)==false) return;

//--- Section A: Main loop of the FOR operator for strategy A -----------
   for(int A=0; A<Strategy_A; A++)
     {
      //--- A.1: Check whether the symbol is allowed to be traded
      if(IsTrade_A[A]==false)
         continue; // terminate the current FOR iteration

      //--- A.2: Upper band of BB calculated based on High prices
      if(CopyBuffer(BB_handle_high_A[A],UPPER_BAND,BBShift_A[A],1,BB_upper_band_high)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(BB_upper_band_high,true);

      //--- A.3: Lower band of BB calculated based on High prices
      if(CopyBuffer(BB_handle_high_A[A],LOWER_BAND,BBShift_A[A],1,BB_lower_band_high)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(BB_lower_band_high,true);

      //--- A.4: Upper band of BB calculated based on Low prices
      if(CopyBuffer(BB_handle_low_A[A],UPPER_BAND,BBShift_A[A],1,BB_upper_band_low)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(BB_upper_band_low,true);

      //--- A.5: Lower band of BB calculated based on Low prices
      if(CopyBuffer(BB_handle_low_A[A],LOWER_BAND,BBShift_A[A],1,BB_lower_band_low)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(BB_lower_band_low,true);

      //--- A.6: Opening time of the current bar
      if(CopyTime(Symbol_A[A],Period_A[A],0,1,time_arr_A)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(time_arr_A,true);

      //--- A.7: Closing a position ---------------------------------------------
      //--- A.7.1: Calculate the current Ask and Bid prices
      SymbolInfo.Name(Symbol_A[A]);
      SymbolInfo.RefreshRates();
      double Ask_price=SymbolInfo.Ask();
      double Bid_price=SymbolInfo.Bid();

      if(PositionSelect(Symbol_A[A]))
        {
         //--- A.7.2: Closing a BUY position
         if(PositionInfo.PositionType()==POSITION_TYPE_BUY)
           {
            if(Bid_price>=BB_lower_band_high[0] || DealNumber_A[A]==0)
              {
               if(!Trade_A.PositionClose(Symbol_A[A]))
                 {
                  Print("Failed to close the Buy ",Symbol_A[A]," position. Code=",Trade_A.ResultRetcode(),
                        " (",Trade_A.ResultRetcodeDescription(),")");
                  continue; // terminate the current FOR iteration
                 }
               else
                 {
                  Print("The Buy ",Symbol_A[A]," position closed successfully. Code=",Trade_A.ResultRetcode(),
                        " (",Trade_A.ResultRetcodeDescription(),")");
                  continue; // terminate the current FOR iteration
                 }
              }
           }
         //--- A.7.3: Closing a SELL position
         if(PositionInfo.PositionType()==POSITION_TYPE_SELL)
           {
            if(Ask_price<=BB_upper_band_low[0] || DealNumber_A[A]==0)
              {
               if(!Trade_A.PositionClose(Symbol_A[A]))
                 {
                  Print("Failed to close the Sell ",Symbol_A[A]," position. Code=",Trade_A.ResultRetcode(),
                        " (",Trade_A.ResultRetcodeDescription(),")");
                  continue; // terminate the current FOR iteration
                 }
               else
                 {
                  Print("The Sell ",Symbol_A[A]," position closed successfully. Code=",Trade_A.ResultRetcode(),
                        " (",Trade_A.ResultRetcodeDescription(),")");
                  continue; // terminate the current FOR iteration
                 }
              }
           }
        }

      //--- A.8: Restrictions on position opening -----------------------------

      //--- A.8.1: Price is in the position closing area
      if(Bid_price>=BB_lower_band_high[0] && Ask_price<=BB_upper_band_low[0])
        {
         DealNumber_A[A]=0;
         continue; // terminate the current FOR iteration
        }

      //--- A.8.2: A position has already been opened on the current bar
      if(Locked_bar_time_A[A]>=time_arr_A[0])
         continue; // terminate the current FOR iteration

      //--- A.9: Opening a position ---------------------------------------------
      SymbolInfo.Name(Symbol_A[A]);
      SymbolInfo.RefreshRates();
      Ask_price=SymbolInfo.Ask();
      Bid_price=SymbolInfo.Bid();

      //--- A.9.1: for a Buy
      if(Ask_price<=BB_lower_band_low[0])
        {
         //--- A.9.1.1: Determine the current deal number
         DealNumber_A[A]++;
         //--- A.9.1.2: Calculate the Lot
         double OrderLot=OrderLotFunc_A(AccountInfo.FreeMargin(),
                                        DealOfFreeMargin_A,
                                        Leverage,
                                        ContractSize_A[A],
                                        DealNumber_A[A],
                                        MinLot_A[A],
                                        MaxLot_A[A]);
         //--- A.9.1.3: Execute a deal
         if(!Trade_A.Buy(OrderLot,Symbol_A[A]))
           {
            //--- if the Buy is unsuccessful, decrease the deal number by 1
            DealNumber_A[A]--;
            Print("The Buy ",Symbol_A[A]," has been unsuccessful. Code=",Trade_A.ResultRetcode(),
                  " (",Trade_A.ResultRetcodeDescription(),")");
            continue; // terminate the current FOR iteration
           }
         else
           {
            //--- save the current time to block the bar for trading
            Locked_bar_time_A[A]=TimeCurrent();
            Print("The Buy ",Symbol_A[A]," has been successful. Code=",Trade_A.ResultRetcode(),
                  " (",Trade_A.ResultRetcodeDescription(),")");
            continue; // terminate the current FOR iteration
           }
        }

      //--- A.9.2: for a Sell
      if(Bid_price>=BB_upper_band_high[0])
        {
         //--- A.9.2.1: Determine the current deal number
         DealNumber_A[A]++;
         //--- A.9.2.2: Calculate the Lot
         double OrderLot=OrderLotFunc_A(AccountInfo.FreeMargin(),
                                        DealOfFreeMargin_A,
                                        Leverage,
                                        ContractSize_A[A],
                                        DealNumber_A[A],
                                        MinLot_A[A],
                                        MaxLot_A[A]);
         //--- A.9.2.3: Execute a deal
         if(!Trade_A.Sell(OrderLot,Symbol_A[A]))
           {
            //--- if the Sell is unsuccessful, decrease the deal number by 1
            DealNumber_A[A]--;
            Print("The Sell ",Symbol_A[A]," has been unsuccessful. Code=",Trade_A.ResultRetcode(),
                  " (",Trade_A.ResultRetcodeDescription(),")");
            continue; // terminate the current FOR iteration
           }
         else
           {
            //--- save the current time to block the bar for trading
            Locked_bar_time_A[A]=TimeCurrent();
            Print("The Sell ",Symbol_A[A]," has been successful. Code=",Trade_A.ResultRetcode(),
                  " (",Trade_A.ResultRetcodeDescription(),")");
            continue; // terminate the current FOR iteration
           }
        }
     } //--- end of the main loop of the FOR operator for strategy A

//--- Section ¬: Main loop of the FOR operator for strategy ¬ -----------
   for(int B=0; B<Strategy_B; B++)
     {
      //--- B.1: Check whether the symbol is allowed to be traded
      if(IsTrade_B[B]==false)
         continue; // terminate the current FOR iteration

      //--- B.2: Opening time of the current bar
      if(CopyTime(Symbol_B[B],TFcode_B[B],0,1,time_arr_B)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(time_arr_B,true);

      //--- B.3: Low prices
      if(CopyLow(Symbol_B[B],TFcode_B[B],0,2,low_arr)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(low_arr,true);

      //--- B.4: High prices
      if(CopyHigh(Symbol_B[B],TFcode_B[B],0,2,high_arr)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(high_arr,true);

      //--- B.5: Open prices
      if(CopyOpen(Symbol_B[B],TFcode_B[B],0,2,open_arr)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(open_arr,true);

      //--- B.6: Close prices
      if(CopyClose(Symbol_B[B],TFcode_B[B],0,2,close_arr)<=0)
         continue; // terminate the current FOR iteration
      ArraySetAsSeries(close_arr,true);

      //--- B.7: Modify the position (set Stop Loss and Take Profit) -----------------------
      if(PositionSelect(Symbol_B[B]))
        {
         //--- save the current time to block the bar for trading
         Locked_bar_time_B[B]=TimeCurrent();
         //---
         if(PositionInfo.StopLoss()==0 || PositionInfo.TakeProfit()==0)
           {
            //--- B.7.1: Modify a Buy position
            if(PositionInfo.PositionType()==POSITION_TYPE_BUY)
              {
               //--- B.7.1.1: Calculated the Stop Loss level
               double StopLoss=PositionInfo.PriceOpen()-StopLoss_B[B]*Point_B[B];
               StopLoss=NormalizeDouble(StopLoss,Digits_B[B]);

               //--- B.7.1.2: Calculate the Take Profit level
               double TakeProfit=PositionInfo.PriceOpen()+TakeProfit_B[B]*Point_B[B];
               TakeProfit=NormalizeDouble(TakeProfit,Digits_B[B]);

               //--- B.7.1.3: Modifying
               if(!Trade_B.PositionModify(Symbol_B[B],StopLoss,TakeProfit))
                 {
                  Print("Failed to modify the Buy ",Symbol_B[B]," position. Code=",Trade_B.ResultRetcode(),
                        " (",Trade_B.ResultRetcodeDescription(),")");
                  continue; // terminate the current FOR iteration
                 }
               else
                 {
                  Print("The Buy ",Symbol_B[B]," position has been modified successfully. Code=",Trade_B.ResultRetcode(),
                        " (",Trade_B.ResultRetcodeDescription(),")");
                  continue; // terminate the current FOR iteration
                 }
              }

            //--- B.7.2: Modify a Sell position
            if(PositionInfo.PositionType()==POSITION_TYPE_SELL)
              {
               //--- B.7.2.1: Calculate the Stop Loss level
               double StopLoss=PositionInfo.PriceOpen()+StopLoss_B[B]*Point_B[B];
               StopLoss=NormalizeDouble(StopLoss,Digits_B[B]);

               //--- B.7.2.2: Calculate the Take Profit level
               double TakeProfit=PositionInfo.PriceOpen()-TakeProfit_B[B]*Point_B[B];
               TakeProfit=NormalizeDouble(TakeProfit,Digits_B[B]);

               //--- B.7.2.3: Modifying
               if(!Trade_B.PositionModify(Symbol_B[B],StopLoss,TakeProfit))
                 {
                  Print("Failed to modify the Sell ",Symbol_B[B]," position. Code=",Trade_B.ResultRetcode(),
                        " (",Trade_B.ResultRetcodeDescription(),")");
                  continue; // terminate the current FOR iteration
                 }
               else
                 {
                  Print("The Sell ",Symbol_B[B]," position has been modified successfully. Code=",Trade_B.ResultRetcode(),
                        " (",Trade_B.ResultRetcodeDescription(),")");
                  continue; // terminate the current FOR iteration
                 }
              }
           }
        }

      //--- B.8: Restrictions on position opening ---------------------------------------------

      //--- B.8.1: Position exists or has already been opened on the current bar
      if(Locked_bar_time_B[B]>=time_arr_B[0])
         continue; // terminate the current FOR iteration

      //--- B.8.2: Calculate the full size of the previous bar (high-low)
      //--- and the size of its body (close-open)
      double FullBarSizeReal=        high_arr[1] -low_arr[1];
      double BodyBarSizeReal=MathAbs(close_arr[1]-open_arr[1]);

      //--- B.8.3: The previous bar does not meet the position opening requirements
      if(FullBarSizeReal<FullBarSize_B[B]*Point_B[B] || 
         BodyBarSizeReal<BodyBarSize_B[B]*Point_B[B])
        {
         Locked_bar_time_B[B]=time_arr_B[0];
         continue; // terminate the current FOR iteration
        }

      //--- B.8.4: The previous bar is neither bullish nor bearish
      if(close_arr[1]==open_arr[1])
        {
         Locked_bar_time_B[B]=time_arr_B[0];
         continue; // terminate the current FOR iteration
        }

      //--- B.9: Opening a position ---------------------------------------------
      //--- B.9.1: Calculate the current Ask and Bid prices
      SymbolInfo.Name(Symbol_B[B]);
      SymbolInfo.RefreshRates();
      double Ask_price=SymbolInfo.Ask();
      double Bid_price=SymbolInfo.Bid();

      //--- B.9.2: Buy if the previous bar is bearish
      if(close_arr[1]<open_arr[1])
        {
         if(Ask_price>=high_arr[1])
           {
            //--- Calculate the Lot
            double OrderLot=OrderLotFunc_B(AccountInfo.FreeMargin(),
                                           DealOfFreeMargin_B,
                                           Leverage,
                                           ContractSize_B[B],
                                           MinLot_B[B],
                                           MaxLot_B[B]);
            //---
            if(!Trade_B.Buy(OrderLot,Symbol_B[B]))
              {
               Print("The Buy ",Symbol_B[B]," has been unsuccessful. Code=",Trade_B.ResultRetcode(),
                     " (",Trade_B.ResultRetcodeDescription(),")");
               continue; // terminate the current FOR iteration
              }
            else
              {
               Print("The Buy ",Symbol_B[B]," has been successful. Code=",Trade_B.ResultRetcode(),
                     " (",Trade_B.ResultRetcodeDescription(),")");
               continue; // terminate the current FOR iteration
              }
           }
        }

      //--- B.9.3: Sell if the previous bar is bullish
      if(close_arr[1]>open_arr[1])
        {
         if(Bid_price<=low_arr[1])
           {
            //--- Calculate the Lot
            double OrderLot=OrderLotFunc_B(AccountInfo.FreeMargin(),
                                           DealOfFreeMargin_B,
                                           Leverage,
                                           ContractSize_B[B],
                                           MinLot_B[B],
                                           MaxLot_B[B]);
            //---
            if(!Trade_B.Sell(OrderLot,Symbol_B[B]))
              {
               Print("The Sell ",Symbol_B[B]," has been unsuccessful. Code=",Trade_B.ResultRetcode(),
                     " (",Trade_B.ResultRetcodeDescription(),")");
               continue; // terminate the current FOR iteration
              }
            else
              {
               Print("The Sell ",Symbol_B[B]," has been successful. Code=",Trade_B.ResultRetcode(),
                     " (",Trade_B.ResultRetcodeDescription(),")");
               continue; // terminate the current FOR iteration
              }
           }
        }
     } //--- end of the main loop of the FOR operator for strategy B
  } */
//-===================== The OnDeinit function ============================
void OnDeinit(const int reason)
  {
//--- Termination of event generation
   EventKillTimer();
//--- Delete indicator handles
   for(int i=0; i<Strategy_A; i++)
     {
      IndicatorRelease(BB_handle_high_A[i]);
      IndicatorRelease(BB_handle_low_A[i]);
     }
  }
//-===================== Function set ============================

//--- The IsSymbolInMarketWatch() function
bool IsSymbolInMarketWatch(string f_Symbol)
  {
   for(int s=0; s<SymbolsTotal(false); s++)
     {
      if(f_Symbol==SymbolName(s,false))
         return(true);
     }
   return(false);
  }
//--- The OrderLotFunc_A() function
double OrderLotFunc_A(double f_FreeMargin,
                      double f_DealOfFreeMargin,
                      long   f_Leverage,
                      double f_ContractSize,
                      uint   f_DealNumber,
                      double f_MinLot,
                      double f_MaxLot
                      )
  {
//--- Calculate the Lot as a certain percent of free margin
   double f_OrderLot=f_FreeMargin*f_DealOfFreeMargin/100*f_Leverage/f_ContractSize;
//--- Lot increase
   f_OrderLot=f_OrderLot*f_DealNumber;
//--- Lot normalization
   f_OrderLot=NormalizeDouble(f_OrderLot,2);
//--- Check if the Lot is too big or too small
   if(f_OrderLot<f_MinLot) return(f_MinLot);
   if(f_OrderLot>f_MaxLot) return(f_MaxLot);
   else return(f_OrderLot);
  }
//--- The OrderLotFunc_B() function
double OrderLotFunc_B(double f_FreeMargin,
                      double f_DealOfFreeMargin,
                      long   f_Leverage,
                      double f_ContractSize,
                      double f_MinLot,
                      double f_MaxLot
                      )
  {
//--- Calculate the Lot as a certain percent of free margin
   double f_OrderLot=f_FreeMargin*f_DealOfFreeMargin/100*f_Leverage/f_ContractSize;
//--- Lot normalization
   f_OrderLot=NormalizeDouble(f_OrderLot,2);
//--- Check if the Lot is too big or too small
   if(f_OrderLot<f_MinLot) return(f_MinLot);
   if(f_OrderLot>f_MaxLot) return(f_MaxLot);
   else return(f_OrderLot);
  }

//+-----------------------------------------+
//| END OF PROGRAM                          |
//+-----------------------------------------+ff