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
                                           
int numsymbols = 14;
input double EURUSDsl = 0.01600;
input double EURUSDtp = 0.03500;
input double GBPUSDsl = 0.03000;
input double GBPUSDtp = 0.04000;
input double AUDUSDsl = 0.05000;
input double AUDUSDtp = 0.06000;
input double EURGBPsl = 0.05000;
input double EURGBPtp = 0.06000;
input double EURCHFsl = 0.05000;
input double EURCHFtp = 0.06000;
input double EURCADsl = 0.03000;
input double EURCADtp = 0.04000;
input double GBPCHFsl = 0.05000;
input double GBPCHFtp = 0.06000;
input double USDCADsl = 0.05000;
input double USDCADtp = 0.06000;
input double USDCHFsl = 0.05000;
input double USDCHFtp = 0.06000;
input double AUDJPYsl = 1.5;
input double AUDJPYtp = 2.0;
input double CHFJPYsl = 1.5;
input double CHFJPYtp = 2.0;
input double EURJPYsl = 1.5;
input double EURJPYtp = 2.0;
input double GBPJPYsl = 1.5;
input double GBPJPYtp = 2.0;
input double USDJPYsl = 1.5;
input double USDJPYtp = 2.0;

double stops[14];
double takes[14];

int OnInit()
{  
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
         //string last   = symbols[i][1];
         
            double EURUSDmovingAverageValues[];
            double GBPUSDmovingAverageValues[];
            double AUDUSDmovingAverageValues[];
            double EURGBPmovingAverageValues[];
            double EURCHFmovingAverageValues[];
            double EURCADmovingAverageValues[];
            double GBPCHFmovingAverageValues[];
            double USDCADmovingAverageValues[];
            double USDCHFmovingAverageValues[];
            double AUDJPYmovingAverageValues[];
            double CHFJPYmovingAverageValues[];
            double EURJPYmovingAverageValues[];
            double GBPJPYmovingAverageValues[];
            double USDJPYmovingAverageValues[];
            
            ArraySetAsSeries(EURUSDmovingAverageValues, true);
            ArraySetAsSeries(GBPUSDmovingAverageValues, true);
            ArraySetAsSeries(AUDUSDmovingAverageValues, true);
            ArraySetAsSeries(EURGBPmovingAverageValues, true);
            ArraySetAsSeries(EURCHFmovingAverageValues, true);
            ArraySetAsSeries(EURCADmovingAverageValues, true);
            ArraySetAsSeries(GBPCHFmovingAverageValues, true);
            ArraySetAsSeries(USDCADmovingAverageValues, true);
            ArraySetAsSeries(USDCHFmovingAverageValues, true);
            ArraySetAsSeries(AUDJPYmovingAverageValues, true);
            ArraySetAsSeries(CHFJPYmovingAverageValues, true);
            ArraySetAsSeries(EURJPYmovingAverageValues, true);
            ArraySetAsSeries(GBPJPYmovingAverageValues, true);
            ArraySetAsSeries(USDJPYmovingAverageValues, true);
            
            if (CopyBuffer(EURUSDhandle,0,0,period,EURUSDmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
            if (CopyBuffer(GBPUSDhandle,0,0,period,GBPUSDmovingAverageValues) < 0){Print("CopyBufferMA2 error =",GetLastError());}
            if (CopyBuffer(AUDUSDhandle,0,0,period,AUDUSDmovingAverageValues) < 0){Print("CopyBufferSAR error =",GetLastError());}
            if (CopyBuffer(EURGBPhandle,0,0,period,EURGBPmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
            if (CopyBuffer(EURCHFhandle,0,0,period,EURCHFmovingAverageValues) < 0){Print("CopyBufferMA2 error =",GetLastError());}
            if (CopyBuffer(EURCADhandle,0,0,period,EURCADmovingAverageValues) < 0){Print("CopyBufferSAR error =",GetLastError());}
            if (CopyBuffer(GBPCHFhandle,0,0,period,GBPCHFmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
            if (CopyBuffer(USDCADhandle,0,0,period,USDCADmovingAverageValues) < 0){Print("CopyBufferMA2 error =",GetLastError());}
            if (CopyBuffer(USDCHFhandle,0,0,period,USDCHFmovingAverageValues) < 0){Print("CopyBufferSAR error =",GetLastError());}
            if (CopyBuffer(USDJPYhandle,0,0,period,USDJPYmovingAverageValues) < 0){Print("CopyBufferMA2 error =",GetLastError());}
            if (CopyBuffer(AUDJPYhandle,0,0,period,AUDJPYmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
            if (CopyBuffer(CHFJPYhandle,0,0,period,CHFJPYmovingAverageValues) < 0){Print("CopyBufferMA2 error =",GetLastError());}
            if (CopyBuffer(EURJPYhandle,0,0,period,EURJPYmovingAverageValues) < 0){Print("CopyBufferSAR error =",GetLastError());}
            if (CopyBuffer(GBPJPYhandle,0,0,period,GBPJPYmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
            if (CopyBuffer(USDJPYhandle,0,0,period,USDJPYmovingAverageValues) < 0){Print("CopyBufferMA1 error =",GetLastError());}
           
            if (symbol=="EURUSD"){ 
      			currentMovingAverage = EURUSDmovingAverageValues[0]; 
      		} 
   			if (symbol=="GBPUSD"){ 
   				currentMovingAverage = GBPUSDmovingAverageValues[0];
   			}
   			if (symbol=="AUDUSD"){ 
      			currentMovingAverage = AUDUSDmovingAverageValues[0];
      		} 
      		if (symbol=="EURGBP"){ 
      			currentMovingAverage = EURGBPmovingAverageValues[0]; 
      		} 
   			if (symbol=="EURCHF"){ 
   				currentMovingAverage = EURCHFmovingAverageValues[0];
   			}
   			if (symbol=="EURCAD"){ 
      			currentMovingAverage = EURCADmovingAverageValues[0];
      		} 
      		if (symbol=="GBPCHF"){ 
      			currentMovingAverage = GBPCHFmovingAverageValues[0]; 
      		} 
   			if (symbol=="USDCAD"){ 
   				currentMovingAverage = USDCADmovingAverageValues[0];
   			}
   			if (symbol=="USDJPY"){ 
      			currentMovingAverage = USDJPYmovingAverageValues[0];
      		} 
      		if (symbol=="USDCHF"){ 
      			currentMovingAverage = USDCHFmovingAverageValues[0]; 
      		} 
   			if (symbol=="AUDJPY"){ 
   				currentMovingAverage = AUDJPYmovingAverageValues[0];
   			}
   			if (symbol=="CHFJPY"){ 
      			currentMovingAverage = CHFJPYmovingAverageValues[0];
      		} 
      		if (symbol=="EURJPY"){ 
   				currentMovingAverage = EURJPYmovingAverageValues[0];
   			}
   			if (symbol=="GBPJPY"){ 
      			currentMovingAverage = GBPJPYmovingAverageValues[0];
      		}
      		if (symbol=="USDJPY"){ 
      			currentMovingAverage = USDJPYmovingAverageValues[0];
      		}
           
            MqlTick ma_tick={0}; 
            SymbolInfoTick(symbol,ma_tick);
            currentprice=ma_tick.bid;
            
            //Print("symbol : " + symbol);
            //Print("current price : " + currentprice);
            //Print("moving average : " + currentMovingAverage);              
                   
            if(OpenPos(symbol)==false && currentprice>currentMovingAverage)
            { 
               MqlTradeRequest request={0}; 
               ZeroMemory(request);
               request.action=TRADE_ACTION_DEAL;            
               request.magic=magic_number;                 
               request.symbol=symbol;                       
               request.volume=1;                            
               request.type=ORDER_TYPE_CLOSE_BY;                 
               MqlTick last_tick={0}; 
               request.deviation=dev;
               SymbolInfoTick(symbol,last_tick);
               request.price=last_tick.bid;                
               request.sl=last_tick.bid-getSL(symbol);                            
               request.tp=last_tick.bid+getTP(symbol); 
               MqlTradeResult result={0};  
               bool success=OrderSend(request,result);
               symbols[i][1]="long";
               return;
            }
            if(OpenPos(symbol)==false && currentprice<currentMovingAverage)
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
               symbols[i][1]="short";
               return;
            }            
      }
        
 
      for(int cnt=0;cnt<PositionsTotal();cnt++)
      {
         if(PositionSelect(PositionGetSymbol(cnt))==true)
         {
            double stop = getSL(PositionGetSymbol(cnt));
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               CTrade trade;
               if(currentprice<currentMovingAverage){
                  trade.PositionClose(PositionGetSymbol(cnt));
               }
            }
         
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               CTrade trade;
               if(currentprice>currentMovingAverage){
                  trade.PositionClose(PositionGetSymbol(cnt));
               }

            }
          }
       }
}

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