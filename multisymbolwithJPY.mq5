

input int OpenOrders = 1;
extern double lotsize = 1.0;

extern double Percentage = 0.65;
input double TrailingStop = 0.03000;
input double TakeProfit = 0.05000; 
input int dev = 25;
extern int closeallvalue = 75000;
extern int tradeincrement = 3600;

int magic_number=0;
int currentbalance = 0;
int currentdate = 0;
datetime lasttrade = 0;
int lasttradelong=0;
int ticket = 0;
string symbols[][2] = {{"AUDJPY","long"},{"CHFJPY","long"},{"EURJPY","long"},
                       {"GBPJPY","long"},{"USDJPY","long"},{"EURCAD","long"},
                       {"GBPCHF","long"},{"USDCAD","long"},{"USDCHF","long"}};
int numsymbols = 5;
input double AUDJPYsl = 0.01000;
input double AUDJPYtp = 0.02000;
input double CHFJPYsl = 0.03000;
input double CHFJPYtp = 0.04000;
input double EURJPYsl = 0.05000;
input double EURJPYtp = 0.06000;
input double GBPJPYsl = 0.05000;
input double GBPJPYtp = 0.06000;
input double USDJPYsl = 0.05000;
input double USDJPYtp = 0.06000;
input double EURCADsl = 0.03000;
input double EURCADtp = 0.04000;
input double GBPCHFsl = 0.05000;
input double GBPCHFtp = 0.06000;
input double USDCADsl = 0.05000;
input double USDCADtp = 0.06000;
input double USDCHFsl = 0.05000;
input double USDCHFtp = 0.06000;

double stops[9];
double takes[9];

int OnInit()
{  
   stops[0]=AUDJPYsl;
   takes[0]=AUDJPYtp;
   
   stops[1]=CHFJPYsl;
   takes[1]=CHFJPYtp;
  
   stops[2]=EURJPYsl;
   takes[2]=EURJPYtp;
   
   stops[3]=GBPJPYsl;
   takes[3]=GBPJPYtp;
   
   stops[4]=USDJPYsl;
   takes[4]=USDJPYtp;
   
   stops[5]=EURCADsl;
   takes[5]=EURCADtp;
  
   stops[6]=GBPCHFsl;
   takes[6]=GBPCHFtp;
   
   stops[7]=USDCADsl;
   takes[7]=USDCADtp;
   
   stops[8]=USDCHFsl;
   takes[8]=USDCHFtp;
   
   return(0);
  // SymbolSelect("GBPUSD",true);
  // SymbolSelect("EURUSD",true);
}

void OnTick()
{

      //if(currentdate != TimeDay(TimeCurrent())){
      //Print("AccountBalanceEURCHF3 = " + AccountBalance());
      //    currentdate= TimeDay(TimeCurrent());
      //}

      //if(AccountEquity()-AccountBalance()>closeallvalue)
      //{
      //   closeall();
      //}
      
      //if (TimeCurrent() >= lasttrade+tradeincrement)
      //{
      //Print("positionsotal:  " + OpenPos()); 
      for(int i=0; i<numsymbols; i++){
         string symbol = symbols[i][0];
         string last   = symbols[i][1];
         //Print("symbol : " + symbol);              
                   
            if(OpenPos(symbol)==false && last=="short")
            {     
               MqlTradeRequest request={0}; 
               ZeroMemory(request);
               request.action=TRADE_ACTION_DEAL;            // setting a pending order 
               request.magic=magic_number;                  // ORDER_MAGIC 
               request.symbol=symbol;                       // symbol 
               request.volume=1;                            // volume in 0.1 lots 
               request.type=ORDER_TYPE_BUY;                 // order type 
               MqlTick last_tick={0}; 
               request.deviation=dev;
               SymbolInfoTick(symbol,last_tick);
               request.price=last_tick.bid;                 // open price 
               request.sl=last_tick.bid-getSL(symbol);                            
               request.tp=last_tick.bid+getTP(symbol); 
               MqlTradeResult result={0};  
               bool success=OrderSend(request,result);
               symbols[i][1]="long";
               return;
            }
            if(OpenPos(symbol)==false && last=="long")
            { 
               MqlTradeRequest request={0}; 
               ZeroMemory(request);
               request.action=TRADE_ACTION_DEAL;            // setting a pending order 
               request.magic=magic_number;                  // ORDER_MAGIC 
               request.symbol=symbol;                       // symbol 
               request.volume=1;   
               request.type=ORDER_TYPE_SELL;                // order type 
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
               //Print("order take profit : " + PositionGetDouble(POSITION_TP));
               if(PositionGetDouble(POSITION_SL)<PositionGetDouble(POSITION_PRICE_CURRENT)-stop-.001)
               {
                  MqlTradeRequest request={0};
                  MqlTradeResult result={0}; 
                  ZeroMemory(request);
                  request.action = TRADE_ACTION_SLTP;
                  request.symbol = PositionGetSymbol(cnt);
                  request.sl = PositionGetDouble(POSITION_PRICE_CURRENT)-stop;
                  request.tp = PositionGetDouble(POSITION_PRICE_OPEN)+getTP(PositionGetSymbol(cnt));
                  Sleep(1000);
                  bool success=OrderSend(request,result);
               }
            }
         
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               if(PositionGetDouble(POSITION_SL)>PositionGetDouble(POSITION_PRICE_CURRENT)+stop+.001)
               {
                  MqlTradeRequest request={0}; 
                  MqlTradeResult result={0};
                  ZeroMemory(request);
                  request.action = TRADE_ACTION_SLTP;
                  request.symbol = PositionGetSymbol(cnt);
                  request.sl = PositionGetDouble(POSITION_PRICE_CURRENT)+stop;
                  request.tp = PositionGetDouble(POSITION_PRICE_OPEN)-getTP(PositionGetSymbol(cnt));
                  Sleep(1000);
                  bool success=OrderSend(request,result);
               }
            }
          }
       }
   //} 
   //}
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