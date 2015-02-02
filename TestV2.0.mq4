//+------------------------------------------------------------------+
//|                                                     TestV2.0.mq4 |
//|                                                          RusLine |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "RusLine"
#property link      ""
#property version   "2.00"
#property strict
//--- input parameters
input int      Диапазон=0;
input int      Прибыль=15;
input double   Лот=0.1;

#define  COUNT_CONST    18
#define  OPEN           1
#define  CLOSE          0

double   r2, r5, r6, r7;
double   s2, s5, s6, s7;
int      oldDay;
int      isCalc;
int      isOpenOrder;
string   name;
int      index;
double   p;

double   fibConsts[COUNT_CONST]={0.236, 0.382, 0.500, 0.618, 0.764, 1.000, 1.236, 1.382, 1.500, 1.618, 1.764, 2.000, 2.236, 2.382, 2.500, 2.618, 2.764, 3.000};
double   rArr[COUNT_CONST];
double   sArr[COUNT_CONST];
int   isRopen[COUNT_CONST];
int   isSopen[COUNT_CONST];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   for(int i = 0; i < COUNT_CONST; i++)
   {
      rArr[i] = 0;
      sArr[i] = 0;
      isRopen[i] = -1;
      isSopen[i] = -1;
   }
   name = "";
   index = 0;
   r2 = 0;
   r5 = 0;
   r6 = 0;
   r7 = 0;
   s2 = 0;
   s5 = 0;
   s6 = 0;
   s7 = 0;
   isCalc = 0;
   isOpenOrder = 0;
   oldDay = DayOfWeek();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }

//+------------------------------------------------------------------+
//| Функция открытия позиции                                 |
//+------------------------------------------------------------------+
int OpenOrder(int cmd)
{
//---
   double point =MarketInfo(Symbol(),MODE_POINT); //Запрос Point
   int ticket;
   if (cmd == OP_SELL)
   {
      double bid = MarketInfo(Symbol(),MODE_BID); // Запрос значения Bid
      ticket = OrderSend(Symbol(), OP_SELL, Лот, bid, 3, 0, 0, NULL, 333, 0, Green);   
   }
   else
   {
      double ask = MarketInfo(Symbol(),MODE_ASK); // Запрос значения Ask
      ticket = OrderSend(Symbol(), OP_BUY, Лот, ask, 3, 0, 0, NULL, 333, 0, Red);
   }
   
   if(ticket > 0)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
         Print("Order opened : ",OrderOpenPrice());
   }
   else
   {
      Alert (GetLastError());
      Print("Error opening order : ",GetLastError());
   }
   return ticket;
}

/*
void OpenOrder(int cmd, double tp)
{
//---
   double point =MarketInfo(Symbol(),MODE_POINT); //Запрос Point
   int ticket;
   if (cmd == OP_SELL)
   {
      double bid = MarketInfo(Symbol(),MODE_BID); // Запрос значения Bid
      ticket = OrderSend(Symbol(), OP_SELL, Лот, bid, 3, 0, bid - Прибыль * point, NULL, 333, 0, Green);   
   }
   else
   {
      double ask = MarketInfo(Symbol(),MODE_ASK); // Запрос значения Ask
      ticket = OrderSend(Symbol(), OP_BUY, Лот, ask, 3, 0, ask + Прибыль * point, NULL, 333, 0, Red);
   }
   
   if(ticket > 0)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
         Print("Order opened : ",OrderOpenPrice());
   }
   else
   {
      Alert (GetLastError());
      Print("Error opening order : ",GetLastError());
   }
}
*/
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   int dayNow;
   dayNow = DayOfWeek();

   if (oldDay != dayNow)
   {
      for(int i = 0; i < COUNT_CONST; i++)
      {
         if (isRopen[i] != -1)
         {
            if (OrderClose(isRopen[i], Лот, Ask, 5, Red))
            {
               isRopen[i] = -1;
            }
            else
            {
               Alert (GetLastError());
               Print("Error closing order : ",GetLastError());
            }
         }   
      }
      oldDay = dayNow;
      isCalc = 1;
      double rates[1][6],yesterday_close,yesterday_high,yesterday_low;
      ArrayCopyRates(rates, Symbol(), PERIOD_D1);
      if(DayOfWeek()==1)
        {
         if(TimeDayOfWeek(iTime(Symbol(),PERIOD_D1,1))==5)
           {
            yesterday_close=rates[1][4];
            yesterday_high=rates[1][3];
            yesterday_low=rates[1][2];
           }
         else
           {
            for(int d=5;d>=0;d--)
              {
               if(TimeDayOfWeek(iTime(Symbol(),PERIOD_D1,d))==5)
                 {
                  yesterday_close=rates[d][4];
                  yesterday_high=rates[d][3];
                  yesterday_low=rates[d][2];
                 }
              }
           }
        }
      else
        {
         yesterday_close=rates[1][4];
         yesterday_high=rates[1][3];
         yesterday_low=rates[1][2];
        }
      //---- Calculate Pivots
      Comment("");
      double R=yesterday_high - yesterday_low;//range
      p = (yesterday_high + yesterday_low + yesterday_close)/3;// Standard Pivot
      
      for(int i = 0; i < COUNT_CONST; i++)
      {
         rArr[i] = p + (R * fibConsts[i]);
         sArr[i] = p - (R * fibConsts[i]);
      }
      r2=p + (R * 0.382);
      r5=p + (R * 0.764);
      r6=p + (R * 1.000);
      r7=p + (R * 1.236);
      
      s2=p - (R * 0.382);
      s5=p - (R * 0.764);
      s6=p - (R * 1.000);
      s7=p - (R * 1.236);
      
      name = "0.000_" + IntegerToString(index, 0, ' ');
      ObjectCreate(name, OBJ_ARROW, 0, iTime(NULL, 0, 0), p);      
      ObjectSet(name, OBJPROP_ARROWCODE, 232);
      ObjectSet(name, OBJPROP_COLOR, clrGreen);
      index++;
     
      for(int i = 0; i < COUNT_CONST; i++)
      {
         name = DoubleToString(fibConsts[i], 3) + "_" + IntegerToString(index, 0, ' ');
         ObjectCreate(name, OBJ_ARROW, 0, iTime(NULL, 0, 0), rArr[i]);      
         ObjectSet(name, OBJPROP_ARROWCODE, 159);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         index++;
         
         name = "-" + DoubleToString(fibConsts[i], 3) + "_" + IntegerToString(index, 0, ' ');
         ObjectCreate(name, OBJ_ARROW, 0, iTime(NULL, 0, 0), sArr[i]);      
         ObjectSet(name, OBJPROP_ARROWCODE, 159);
         ObjectSet(name, OBJPROP_COLOR, clrRed);
         index++;
      }

   }
   
   if (isCalc)
   {
      double oldBar[1][6];
      ArrayCopyRates(oldBar, Symbol(), PERIOD_M15);
      
      //if (!OrderSelect(1, SELECT_BY_POS, MODE_TRADES))
      //if (!OrdersTotal())
      //{
         /*if (oldBar[1][4] > (r2 - Диапазон*Point))
         {
            OpenOrder(OP_SELL);
         }
         
         if (oldBar[1][4] < (s2 + Диапазон*Point))
         {
            OpenOrder(OP_BUY);
         }*/
         
         for(int i = 0; i < COUNT_CONST; i++)
         {
            if (oldBar[1][4] > (rArr[i] - Диапазон*Point) && isRopen[i] == -1)
            {
               if (i > 0)
               {
                  isRopen[i] = OpenOrder(OP_SELL);
               }
               else
               {
                  isRopen[i] = OpenOrder(OP_SELL);
               }
            }
            
            if (isRopen[i] != -1)
            {
               if (i > 0)
               {
                  if (oldBar[1][4] < rArr[i - 1])
                  {
                     if (OrderClose(isRopen[i], Лот, Ask, 5, Red))
                     {
                        isRopen[i] = -1;
                     }
                     else
                     {
                        Alert (GetLastError());
                        Print("Error closing order : ",GetLastError());
                     }
                  }
               }
               else
               {
                  if (oldBar[1][4] < p)
                  {
                     if (OrderClose(isRopen[i], Лот, Ask, 5, Red))
                     {
                        isRopen[i] = -1;
                     }
                     else
                     {
                        Alert (GetLastError());
                        Print("Error closing order : ",GetLastError());
                     }
                  }
               }
            }
         }
      //}
   }
}
//+------------------------------------------------------------------+
