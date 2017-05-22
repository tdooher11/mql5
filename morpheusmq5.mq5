input int OpenOrders = 1;
extern double lotsize = 1.0;

extern double Percentage = 0.65;
input double TrailingStop = 0.03000;
input double TakeProfit = 0.05000; 
extern int closeallvalue = 75000;
extern int tradeincrement = 3600;

int magic_number=0;

int currentbalance = 0;
int currentdate = 0;
datetime lasttrade = 0;
int lasttradelong=0;
int ticket = 0;

int init()
{
   MathSrand(TimeLocal());  
   return(0);
}

void OnTick()
{

     // if(currentdate != TimeDay(TimeCurrent())){
         //Print("AccountBalanceEURCHF3 = " + AccountBalance());
     //    currentdate= TimeDay(TimeCurrent());
     // }

      //if(AccountEquity()-AccountBalance()>closeallvalue)
    //  {
      //   closeall();
     // }
      
      if (TimeCurrent() >= lasttrade+tradeincrement)
      {
      //Print("positionsotal:  " + OpenPos());
      if(OpenPos()<OpenOrders)
      {  
         
         if(lasttradelong==1)
         {     
            MqlTradeRequest request={0}; 
            ZeroMemory(request);
            request.action=TRADE_ACTION_DEAL;         // setting a pending order 
            request.magic=magic_number;                  // ORDER_MAGIC 
            request.symbol=_Symbol;                      // symbol 
            request.volume=1;                          // volume in 0.1 lots 
            request.type=ORDER_TYPE_BUY;                 // order type 
            MqlTick last_tick={0}; 
            request.deviation=10;
            SymbolInfoTick(Symbol(),last_tick);
            request.price=last_tick.bid;                 // open price 
            request.sl=last_tick.bid-TrailingStop;                            
            request.tp=last_tick.bid+TakeProfit; 
            MqlTradeResult result={0};  
            bool success=OrderSend(request,result);
            lasttradelong=0;
            return;
         }
         if(lasttradelong==0)
         { 
            MqlTradeRequest request={0}; 
            ZeroMemory(request);
            request.action=TRADE_ACTION_DEAL;         // setting a pending order 
            request.magic=magic_number;                  // ORDER_MAGIC 
            request.symbol=_Symbol;                      // symbol 
            request.volume=1;   
            request.type=ORDER_TYPE_SELL;                // order type 
            MqlTick last_tick={0};
            request.deviation=10;
            SymbolInfoTick(Symbol(),last_tick); 
            request.price=last_tick.ask;       
            request.sl=last_tick.ask+TrailingStop;                             
            request.tp=last_tick.ask-TakeProfit; 
            MqlTradeResult result={0}; 
            bool success=OrderSend(request,result);
           lasttradelong=1;
           return;
         }            
      }  
         
      for(int cnt=0;cnt<PositionsTotal();cnt++)
      {
         if(PositionSelect(PositionGetSymbol(cnt))==true)
         {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               if(PositionGetDouble(POSITION_SL)<PositionGetDouble(POSITION_PRICE_CURRENT)-TrailingStop)
               {
                  MqlTradeRequest request={0};
                  MqlTradeResult result={0}; 
                  ZeroMemory(request);
                  request.action = TRADE_ACTION_SLTP;
                  request.symbol = Symbol();
                  request.sl = PositionGetDouble(POSITION_PRICE_CURRENT)-TrailingStop;
                  bool success=OrderSend(request,result);
               }
            }
         
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               if(PositionGetDouble(POSITION_SL)>PositionGetDouble(POSITION_PRICE_CURRENT)+TrailingStop)
               {
                  MqlTradeRequest request={0}; 
                  MqlTradeResult result={0};
                  ZeroMemory(request);
                  request.action = TRADE_ACTION_SLTP;
                  request.symbol = Symbol();
                  request.sl = PositionGetDouble(POSITION_PRICE_CURRENT)+TrailingStop;
                  bool success=OrderSend(request,result);
               }
            }
         }
      }
   //}
   
   }
}

int OpenPos()
{
   int total=PositionsTotal();
   int count=0;
   for (int cnt=0; cnt<=total-1; cnt++) 
      {
         if(PositionSelect(Symbol()) )
            {
               count++; 
            }
      }

    return(count);
}
