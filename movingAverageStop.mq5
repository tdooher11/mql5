#include <trade/trade.mqh>

input int dev = 25;
int magic_number=0;

double currentprice=0.0000;
double currentMovingAverage=0.0000;
double movingAverageValues[];
input int period = 21;

int EURUSDhandle = 0;
int GBPUSDhandle = 0;
int AUDUSDhandle = 0;
int EURGBPhandle = 0;
int EURCHFhandle = 0;
int EURCADhandle = 0;
int GBPCHFhandle = 0;
int USDCADhandle = 0;
int USDCHFhandle = 0;
int AUDJPYhandle = 0;
int CHFJPYhandle = 0;
int EURJPYhandle = 0;
int GBPJPYhandle = 0;
int USDJPYhandle = 0;

string symbols[][2] = {{"EURUSD","long"},{"GBPUSD","long"},{"AUDUSD","long"},
                       {"EURGBP","long"},{"EURCHF","long"},{"EURCAD","long"},
                       {"GBPCHF","long"},{"USDCAD","long"},{"USDCHF","long"},
                       {"AUDJPY","long"},{"CHFJPY","long"},{"EURJPY","long"},
                       {"GBPJPY","long"},{"USDJPY","long"}};

int numsymbols = 1;
input double EURUSDsl = 0.5;
input double EURUSDtp = 0.5;
input double GBPUSDsl = 0.5;
input double GBPUSDtp = 0.5;
input double AUDUSDsl = 0.5;
input double AUDUSDtp = 0.5;
input double EURGBPsl = 0.5;
input double EURGBPtp = 0.5;
input double EURCHFsl = 0.5;
input double EURCHFtp = 0.5;
input double EURCADsl = 0.5;
input double EURCADtp = 0.5;
input double GBPCHFsl = 0.5;
input double GBPCHFtp = 0.5;
input double USDCADsl = 0.5;
input double USDCADtp = 0.5;
input double USDCHFsl = 0.5;
input double USDCHFtp = 0.5;
input double AUDJPYsl = 50.0;
input double AUDJPYtp = 50.0;
input double CHFJPYsl = 50.0;
input double CHFJPYtp = 50.0;
input double EURJPYsl = 50.0;
input double EURJPYtp = 50.0;
input double GBPJPYsl = 50.0;
input double GBPJPYtp = 50.0;
input double USDJPYsl = 50.0;
input double USDJPYtp = 50.0;

double stops[14];
double takes[14];

int OnInit()
{
Print("inside oninit");
   stops[0]=EURUSDsl;
   takes[0]=EURUSDtp;

   stops[1]=GBPUSDsl;
   takes[1]=GBPUSDtp;

   stops[2]=AUDUSDsl;
   takes[2]=AUDUSDtp;

   stops[3]=EURGBPsl;
   takes[3]=EURGBPtp;

   stops[4]=EURCHFsl;
   takes[4]=EURCHFtp;

   stops[5]=EURCADsl;
   takes[5]=EURCADtp;

   stops[6]=GBPCHFsl;
   takes[6]=GBPCHFtp;

   stops[7]=USDCADsl;
   takes[7]=USDCADtp;

   stops[8]=USDCHFsl;
   takes[8]=USDCHFtp;

   stops[9]=AUDJPYsl;
   takes[9]=AUDJPYtp;

   stops[10]=CHFJPYsl;
   takes[10]=CHFJPYtp;

   stops[11]=EURJPYsl;
   takes[11]=EURJPYtp;

   stops[12]=GBPJPYsl;
   takes[12]=GBPJPYtp;

   stops[13]=USDJPYsl;
   takes[13]=USDJPYtp;

   EURUSDhandle=iMA("EURUSD",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   GBPUSDhandle=iMA("GBPUSD",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   AUDUSDhandle=iMA("AUDUSD",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   EURGBPhandle=iMA("EURGBP",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   EURCHFhandle=iMA("EURCHF",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   EURCADhandle=iMA("EURCAD",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   GBPCHFhandle=iMA("GBPCHF",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   USDCADhandle=iMA("USDCAD",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   USDCHFhandle=iMA("USDCHF",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   AUDJPYhandle=iMA("AUDJPY",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   CHFJPYhandle=iMA("CHFJPY",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   EURJPYhandle=iMA("EURJPY",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   GBPJPYhandle=iMA("GBPJPY",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);
   USDJPYhandle=iMA("USDJPY",PERIOD_H4,period,0,MODE_SMA,PRICE_CLOSE);

   return(0);
}

void OnTick()
{

      for(int i=0; i<numsymbols; i++){
         string symbol = symbols[i][0];
            //Print(symbol);
            double currentMovingAverage=calculateMovingAverage(symbol);
            
            MqlTick ma_tick={0};
            SymbolInfoTick(symbol,ma_tick);
            currentprice=ma_tick.bid;

            if(OpenPos(symbol)==false && currentprice<currentMovingAverage)
            {
               MqlTradeRequest request={0};
               ZeroMemory(request);
               request.action=TRADE_ACTION_DEAL;
               request.magic=magic_number;
               request.symbol=symbol;
               request.volume=1;
               request.type=ORDER_TYPE_BUY;
               MqlTick last_tick={0};
               request.deviation=dev;
               SymbolInfoTick(symbol,last_tick);
               request.price=last_tick.bid;
               request.sl=last_tick.bid-getSL(symbol);
               request.tp=last_tick.bid+getTP(symbol);
               MqlTradeResult result={0};
               bool success=OrderSend(request,result);
               return;
            }
            if(OpenPos(symbol)==false && currentprice>currentMovingAverage)
            {
               MqlTradeRequest request={0};
               ZeroMemory(request);
               request.action=TRADE_ACTION_DEAL;
               request.magic=magic_number;
               request.symbol=symbol;
               request.volume=1;
               request.type=ORDER_TYPE_SELL;
               MqlTick last_tick={0};
               request.deviation=dev;
               SymbolInfoTick(symbol,last_tick);
               request.price=last_tick.ask;
               request.sl=last_tick.ask+getSL(symbol);
               request.tp=last_tick.ask-getTP(symbol);
               MqlTradeResult result={0};
               bool success=OrderSend(request,result);
               return;
            }
            
      }//end position open for loop

      for(int cnt=0;cnt<PositionsTotal();cnt++)
      {
         if(PositionSelect(PositionGetSymbol(cnt))==true)
         {
            MqlTick ma_tick={0};
            SymbolInfoTick(PositionGetSymbol(cnt),ma_tick);
            currentprice=ma_tick.bid;
            
            double currentMovingAverage=calculateMovingAverage(PositionGetSymbol(cnt));
            
            //Print("symbol : " + PositionGetSymbol(cnt) + " currentMovingAverage : " + currentMovingAverage + " currentPrice : " + currentprice);
            PositionGetInteger(POSITION_MAGIC);
            Print("position get type
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               CTrade trade;
               if(currentprice>currentMovingAverage){
                  Print(" --CLOSING-- long trade for symbol : " + PositionGetSymbol(cnt) + " currentMovingAverage : " + currentMovingAverage + " currentPrice : " + currentprice);
                  trade.PositionClose(PositionGetSymbol(cnt));
               }
            }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               CTrade trade;
               if(currentprice<currentMovingAverage){
                   Print(" --CLOSING-- short trade for symbol : " + PositionGetSymbol(cnt) + " currentMovingAverage : " + currentMovingAverage + " currentPrice : " + currentprice);
                  trade.PositionClose(PositionGetSymbol(cnt));
               }
            }
          }
       }//end trailing stop for loop
      
}//end ontick

bool OpenPos(string symbol)
{
   int total=PositionsTotal();
   int count=0;
   bool currentopen=false;

   for (int cnt=0; cnt<=total-1; cnt++)
   {
      if(PositionSelect(symbol) )
      {
         currentopen=true;
         count++;
      }
   }
   return(currentopen);
}

double getSL(string symbol)
{
   double sl = 0.0;
   for(int i=0; i<numsymbols; i++){
         string currentsymbol = symbols[i][0];
         if (symbol==currentsymbol)
         {
            sl = stops [i];
         }
   }
   return sl;
}

double getTP(string symbol)
{
   double tp = 0.0;
   for(int i=0; i<numsymbols; i++){
         string currentsymbol = symbols[i][0];
         if (symbol==currentsymbol)
         {
            tp = takes [i];
         }
   }
   return tp;
}


double calculateMovingAverage(string symbol){

    if (symbol=="EURUSD"){
      double EURUSDmovingAverageValues[];
      ArraySetAsSeries(EURUSDmovingAverageValues, true);
      if (CopyBuffer(EURUSDhandle,0,0,period,EURUSDmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
      currentMovingAverage = EURUSDmovingAverageValues[0];
    }
    if (symbol=="GBPUSD"){
      double GBPUSDmovingAverageValues[];
      ArraySetAsSeries(GBPUSDmovingAverageValues, true);
      if (CopyBuffer(GBPUSDhandle,0,0,period,GBPUSDmovingAverageValues) < 0){Print("CopyBufferMA2 error =",GetLastError());}
      currentMovingAverage = GBPUSDmovingAverageValues[0];
    }
    if (symbol=="AUDUSD"){
      double AUDUSDmovingAverageValues[];
      ArraySetAsSeries(AUDUSDmovingAverageValues, true);
      if (CopyBuffer(AUDUSDhandle,0,0,period,AUDUSDmovingAverageValues) < 0){Print("CopyBufferSAR error =",GetLastError());}
      currentMovingAverage = AUDUSDmovingAverageValues[0];
    }
    if (symbol=="EURGBP"){
      double EURGBPmovingAverageValues[];
      ArraySetAsSeries(EURGBPmovingAverageValues, true);
      if (CopyBuffer(EURGBPhandle,0,0,period,EURGBPmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
      currentMovingAverage = EURGBPmovingAverageValues[0];
    }
    if (symbol=="EURCHF"){
      double EURCHFmovingAverageValues[];
      ArraySetAsSeries(EURCHFmovingAverageValues, true);
      if (CopyBuffer(EURCHFhandle,0,0,period,EURCHFmovingAverageValues) < 0){Print("CopyBufferMA2 error =",GetLastError());}
      currentMovingAverage = EURCHFmovingAverageValues[0];
    }
    if (symbol=="EURCAD"){
      double EURCADmovingAverageValues[];
      ArraySetAsSeries(EURCADmovingAverageValues, true);
      if (CopyBuffer(EURCADhandle,0,0,period,EURCADmovingAverageValues) < 0){Print("CopyBufferSAR error =",GetLastError());}
      currentMovingAverage = EURCADmovingAverageValues[0];
    }
    if (symbol=="GBPCHF"){
      double GBPCHFmovingAverageValues[];
      ArraySetAsSeries(GBPCHFmovingAverageValues, true);
      if (CopyBuffer(GBPCHFhandle,0,0,period,GBPCHFmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
      currentMovingAverage = GBPCHFmovingAverageValues[0];
    }   
    if (symbol=="USDCAD"){
      double USDCADmovingAverageValues[];
      ArraySetAsSeries(USDCADmovingAverageValues, true);
      if (CopyBuffer(USDCADhandle,0,0,period,USDCADmovingAverageValues) < 0){Print("CopyBufferMA2 error =",GetLastError());}
      currentMovingAverage = USDCADmovingAverageValues[0];
    } 
    if (symbol=="USDCHF"){
      double USDCHFmovingAverageValues[];
      ArraySetAsSeries(USDCHFmovingAverageValues, true);
      if (CopyBuffer(USDCHFhandle,0,0,period,USDCHFmovingAverageValues) < 0){Print("CopyBufferSAR error =",GetLastError());}
      currentMovingAverage = USDCHFmovingAverageValues[0];
    }
    if (symbol=="AUDJPY"){
      double AUDJPYmovingAverageValues[];
      ArraySetAsSeries(AUDJPYmovingAverageValues, true);
      if (CopyBuffer(AUDJPYhandle,0,0,period,AUDJPYmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
      currentMovingAverage = AUDJPYmovingAverageValues[0];
    }
    if (symbol=="CHFJPY"){
      double CHFJPYmovingAverageValues[];
      ArraySetAsSeries(CHFJPYmovingAverageValues, true);
      if (CopyBuffer(CHFJPYhandle,0,0,period,CHFJPYmovingAverageValues) < 0){Print("CopyBufferMA2 error =",GetLastError());}
      currentMovingAverage = CHFJPYmovingAverageValues[0];
    }
    if (symbol=="EURJPY"){
      double EURJPYmovingAverageValues[];
      ArraySetAsSeries(EURJPYmovingAverageValues, true);
      if (CopyBuffer(EURJPYhandle,0,0,period,EURJPYmovingAverageValues) < 0){Print("CopyBufferSAR error =",GetLastError());}
      currentMovingAverage = EURJPYmovingAverageValues[0];
    }
    if (symbol=="GBPJPY"){
      double GBPJPYmovingAverageValues[];
      ArraySetAsSeries(GBPJPYmovingAverageValues, true);
      if (CopyBuffer(GBPJPYhandle,0,0,period,GBPJPYmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
      currentMovingAverage = GBPJPYmovingAverageValues[0];
    }
    if (symbol=="USDJPY"){
      double USDJPYmovingAverageValues[];
      ArraySetAsSeries(USDJPYmovingAverageValues, true);
      if (CopyBuffer(USDJPYhandle,0,0,period,USDJPYmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
      currentMovingAverage = USDJPYmovingAverageValues[0];
    }   
    return currentMovingAverage;
}

