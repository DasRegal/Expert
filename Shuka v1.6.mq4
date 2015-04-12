//+------------------------------------------------------------------+
//|                                                   Shuka v1.6.mq4 |
//|                                                          RusLine |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "RusLine"
#property link      ""
#property version   "1.60"
#property strict

//--- input parameters
input int      Прибыль=10;
input int      Множитель=1;
input int      КоличествоЛотов=8;
input int      Разница=2;
input int      Шаг=100;
input int      Рогатка=300;
input int      Диапазон=0;
input int      Лось=0;

#define  COUNT_CONST    18

int      oldDay;
int      dayNow;
string   name_obj;
int      index;
double   pivot;

double   rArr[COUNT_CONST];
double   sArr[COUNT_CONST];
double   arrOfLots[COUNT_CONST];
int      countOfLots;
int      isRopen[COUNT_CONST];
int      isSopen[COUNT_CONST];
int      isCanROpen[COUNT_CONST];
int      isCanSOpen[COUNT_CONST];
bool     reinit;


datetime LastDay;



bool NewBar(int tf, datetime &lastbar)
{
   datetime curbar = iTime(_Symbol, tf, 0);
   if(lastbar != curbar)
    {
     lastbar = curbar;
     return (true);
    }
   else return(false);
}

void CalculateDay()
{

   dayNow = DayOfWeek();

   bool NewDay;
   NewDay = NewBar(PERIOD_D1, LastDay);

   //if (oldDay != dayNow || reinit)
   if (NewDay || reinit)
   {
      if (!reinit)
      {
         for(int i = 0; i < COUNT_CONST; i++)
         {
            isCanROpen[i] = 1;
            isCanSOpen[i] = 1;
         }
      }
      if (reinit) reinit = 0;
      
      oldDay = dayNow;
      
      datetime timeNow, timeOfStartDay;
      timeNow = iTime(NULL, 0, 0);
      MqlDateTime str1;
      TimeToStruct(timeNow, str1);
      str1.hour = 0;
      str1.min = 0;
      timeOfStartDay = StructToTime(str1);
            
      double yesterday_close,yesterday_high,yesterday_low;
      //---- Calculate Pivots

      yesterday_high = iHigh(NULL, PERIOD_D1, 1);
      yesterday_low = iLow(NULL, PERIOD_D1, 1);
      yesterday_close = iClose(NULL, PERIOD_D1, 1);

      double R=yesterday_high - yesterday_low;//range
      pivot = (yesterday_high + yesterday_low + yesterday_close)/3;// Standard Pivot
      
      for(int i = 0; i < COUNT_CONST; i++)
      {
         rArr[i] = pivot + (i * Шаг * Point) + (Рогатка) * Point;
         sArr[i] = pivot - (i * Шаг * Point) - (Рогатка) * Point;
      }
      
      name_obj = "0.000_" + IntegerToString(index, 0, ' ');
      ObjectCreate(name_obj, OBJ_ARROW, 0, timeOfStartDay, pivot+3*Point);      
      ObjectSet(name_obj, OBJPROP_ARROWCODE, 232);
      ObjectSet(name_obj, OBJPROP_COLOR, clrGreen);
      index++;
     
      for(int i = 0; i < COUNT_CONST; i++)
      {
         name_obj = IntegerToString(i, 0, ' ') + "_" + IntegerToString(index, 0, ' ');
         ObjectCreate(name_obj, OBJ_ARROW, 0, timeOfStartDay, rArr[i]+3*Point);      
         ObjectSet(name_obj, OBJPROP_ARROWCODE, 159);
         ObjectSet(name_obj, OBJPROP_COLOR, clrRed);
         index++;
         
         name_obj = "-" + IntegerToString(i, 0, ' ') + "_" + IntegerToString(index, 0, ' ');
         ObjectCreate(name_obj, OBJ_ARROW, 0, timeOfStartDay, sArr[i]+3*Point);      
         ObjectSet(name_obj, OBJPROP_ARROWCODE, 159);
         ObjectSet(name_obj, OBJPROP_COLOR, clrRed);
         index++;
      }
   }
}

bool isReset = false;
bool isChoseR = false;
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
//--- сбросим значение ошибки
   ResetLastError();
//--- проверка события нажатия на кнопку мыши

   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if (sparam == "Reset")
      {
         ObjectSetInteger(0,"Reset",OBJPROP_STATE,false);
         isReset = true;
         OnInit();
      }
      if(sparam=="Change")
      {
         if (isChoseR)
         {
            isChoseR = false;
            ButtonTextChange(0, "Change", "S");
            for (int i = 0; i < COUNT_CONST; i++)
            {
               ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
               if (isSopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
               else ButtonTextChange(0, "But"+i, 0);
            }
         }
         else
         {
            isChoseR = true;
            ButtonTextChange(0, "Change", "R");
            for (int i = 0; i < COUNT_CONST; i++)
            {
               ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanROpen[i]);
               if (isRopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
               else ButtonTextChange(0, "But"+i, 0);
            }
         }
      }
      
      for (int i = 0; i < COUNT_CONST; i++)
      {
         if(sparam==("But"+i))
         {
            if (!isChoseR)
            {
               if (isCanSOpen[i])
               {
                  isCanSOpen[i] = 0;
                  
               }
               else
               {
                  isCanSOpen[i] = 1;
                  
               }
               ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
            }
            else
            {
               if (isCanROpen[i])
               {
                  isCanROpen[i] = 0;
                  
               }
               else
               {
                  isCanROpen[i] = 1;
                  
               }
               ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanROpen[i]);
            }
         }
      }
      
   }
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ObjectsDeleteAll();
   name_obj = "";
   index = 0;
   
   int x;
   int y, k = 0;
   x = 20;
   y = 40;
   ButtonCreate(0,"Reset",0,x+1,y-20,62,20,InpCorner,"Сброс",InpFont,InpFontSize, InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);
   ButtonCreate(0,"Change",0,x+64,y-20,62,20,InpCorner,"Изменить",InpFont,InpFontSize, InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);
   ButtonTextChange(0, "Change", "S");
   ObjectSetInteger(0,"Reset",OBJPROP_STATE,false);
   for (int i = 1; i <= 3; i++)
   {
      for (int j = 1; j <= 6; j++)
      {
         ButtonCreate(0,"But"+k,0,x*j+j,y,20,20,InpCorner,(string)10,InpFont,InpFontSize, InpColor,InpBackColor,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);
         k++;
      }
      y = y + 20;
   }

   ObjectSetInteger(0,"Change",OBJPROP_STATE,isChoseR);
   
   if (GlobalVariableGet("ReasonDeinit" + Symbol()) == 1 || isReset) // Программа удалена с графика
   {
      isReset = false;
      reinit = 0;
      oldDay = DayOfWeek() - 1;
      if (oldDay < 0) oldDay = 5;
      
      LastDay = iTime(Symbol(), PERIOD_D1, 1);
      
      arrOfLots[0] = MarketInfo(Symbol(), MODE_MINLOT);
      for (int i = 1; i < КоличествоЛотов; i++)
      {
         arrOfLots[i] = arrOfLots[i - 1] * Разница;
      }
      for (int i = КоличествоЛотов; i < COUNT_CONST; i++)
      {
         arrOfLots[i] = arrOfLots[КоличествоЛотов - 1] * Разница;
      }
      
      for (int i = 0; i < COUNT_CONST; i++)
      {
         arrOfLots[i] *= Множитель;
      }
      
      countOfLots = 0;
      for(int i = 0; i < COUNT_CONST; i++)
      {
         rArr[i] = 0;
         sArr[i] = 0;
         isRopen[i] = -1;
         isSopen[i] = -1;
         isCanROpen[i] = 1;
         isCanSOpen[i] = 1;
      }

      CalculateDay();
      for(int i = 0; i < COUNT_CONST; i++)
      {
         if (iClose(NULL, PERIOD_M1, 0) > (rArr[i] - Диапазон*Point))
         {
            isCanROpen[i] = 0;
         }
   
         if (iClose(NULL, PERIOD_M1, 0) < (sArr[i] + Диапазон*Point))
         {
            isCanSOpen[i] = 0;
         }
      }   
      
      for (int i = 0; i < COUNT_CONST; i++)
      {
         ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
         if (isSopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
         else ButtonTextChange(0, "But"+i, 0);
      }
      return(INIT_SUCCEEDED);
   }
   
   oldDay = GlobalVariableGet("oldDay" + Symbol());
   dayNow = GlobalVariableGet("dayNow" + Symbol());
   for (int i = 0; i < COUNT_CONST; i++)
   {
      rArr[i] = GlobalVariableGet("rArr" + i + Symbol());
      sArr[i] = GlobalVariableGet("sArr" + i + Symbol());
      arrOfLots[i] = GlobalVariableGet("arrOfLots" + i + Symbol());
      isRopen[i] = GlobalVariableGet("isRopen" + i + Symbol());
      isSopen[i] = GlobalVariableGet("isSopen" + i + Symbol());
      isCanROpen[i] = GlobalVariableGet("isCanROpen" + i + Symbol());
      isCanSOpen[i] = GlobalVariableGet("isCanSOpen" + i + Symbol());
   }
   for (int i = 0; i < COUNT_CONST; i++)
   {
      ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
      if (isSopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
      else ButtonTextChange(0, "But"+i, 0);
   }
   countOfLots = GlobalVariableGet("countOfLots" + Symbol());
   reinit = 1;
   CalculateDay();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   ObjectsDeleteAll();
   
   GlobalVariableSet("ReasonDeinit" + Symbol(), reason);
   GlobalVariableSet("countOfLots" + Symbol(), countOfLots);
   GlobalVariableSet("oldDay" + Symbol(), oldDay);
   GlobalVariableSet("dayNow" + Symbol(), dayNow);
   for (int i = 0; i < COUNT_CONST; i++)
   {
      GlobalVariableSet("rArr" + i + Symbol(), rArr[i]);
      GlobalVariableSet("sArr" + i + Symbol(), sArr[i]);
      GlobalVariableSet("arrOfLots" + i + Symbol(), arrOfLots[i]);
      GlobalVariableSet("isRopen" + i + Symbol(), isRopen[i]);
      GlobalVariableSet("isSopen" + i + Symbol(), isSopen[i]);
      GlobalVariableSet("isCanROpen" + i + Symbol(), isCanROpen[i]);
      GlobalVariableSet("isCanSOpen" + i + Symbol(), isCanSOpen[i]);
   }
}

//+------------------------------------------------------------------+
//| Функция открытия позиции                                         |
//+------------------------------------------------------------------+
int OpenOrder(int cmd)
{
//---
   int ticket;
   if (cmd == OP_SELL)
   {
      double bid = MarketInfo(Symbol(),MODE_BID); // Запрос значения Bid
      double bid1, bid2;
      if (Лось == 0) bid1 = 0;
      else bid1 = MarketInfo(Symbol(),MODE_BID); // Запрос значения Ask
      if (Прибыль == 0) bid2 = 0;
      else bid2 = MarketInfo(Symbol(),MODE_BID); // Запрос значения Ask
      //ticket = OrderSend(Symbol(), OP_SELL, arrOfLots[countOfLots], bid, 5, NormalizeDouble(bid1+Лось*Point,Digits), NormalizeDouble(bid2-Прибыль*Point,Digits), NULL, 0, 0, Green); 
      ticket = OrderSend(Symbol(), OP_SELL, arrOfLots[countOfLots], bid, 5, 0, NormalizeDouble(bid2-Прибыль*Point,Digits), NULL, 0, 0, Green); 
   }
   else
   {
      double ask = MarketInfo(Symbol(),MODE_ASK); // Запрос значения Ask
      
      double ask1, ask2;
      if (Лось == 0) ask1 = 0;
      else ask1 = MarketInfo(Symbol(),MODE_ASK); // Запрос значения Ask
      if (Прибыль == 0) ask2 = 0;
      else ask2 = MarketInfo(Symbol(),MODE_ASK); // Запрос значения Ask
      //ticket = OrderSend(Symbol(), OP_BUY, arrOfLots[countOfLots], ask, 5, NormalizeDouble(ask1-Лось*Point,Digits), NormalizeDouble(ask2+Прибыль*Point,Digits), NULL, 0, 0, Red);
      ticket = OrderSend(Symbol(), OP_BUY, arrOfLots[countOfLots], ask, 5, 0, NormalizeDouble(ask2+Прибыль*Point,Digits), NULL, 0, 0, Red);
   }
   
   if(ticket > 0)
   {
      //if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      //   Print("Order opened : ", " "OrderOpenPrice());
      IncLots();
      return ticket;
   }
   else
   {
      if (ticket == 0) return -1;
      int err;
      err = GetLastError();
      //Alert ("Ошибка открытия: ", err);
      Print("Error opening order : ", err, "; Лот: ",arrOfLots[countOfLots]);
   }
   return -1;
}

void IncLots()
{
   countOfLots++;
   if (countOfLots >= COUNT_CONST) countOfLots = COUNT_CONST - 1;
}

//int CloseAllOrders(int pos){
//   for(int i = 0; i < COUNT_CONST; i++)
//   {
//      if ( i != pos)
//      {
//         if (isSopen[i] != -1)
//         {
//            if(OrderSelect(isSopen[i], SELECT_BY_TICKET, MODE_TRADES))
//            {
//               if (OrderClose(isSopen[i], OrderLots(), Bid, 5, Red))
//               {
//                  isSopen[i] = -1;
//                  //return 1;
//               }
//               else
//               {
//                  int err;
//                  err = GetLastError();
//                  if (err == ERR_INVALID_TICKET) isSopen[i] = -1;
//                  //else Alert ("Ошибка закрытия: ", err);
//                  Print("Error closing order : ",err);
//                  return 0;
//               }
//            }
//         }
//      
//      
//         if (isRopen[i] != -1)
//         {
//            if(OrderSelect(isRopen[i], SELECT_BY_TICKET, MODE_TRADES))
//            {
//               if (OrderClose(isRopen[i], OrderLots(), Bid, 5, Red))
//               {
//                  isRopen[i] = -1;
//                  //return 1;
//               }
//               else
//               {
//                  int err;
//                  err = GetLastError();
//                  if (err == ERR_INVALID_TICKET) isRopen[i] = -1;
//                  //else Alert ("Ошибка закрытия: ", err);
//                  Print("Error closing order : ",err);
//                  return 0;
//               }
//            }
//         }
//      }
//   }
//   return 1;
//}

bool CloseOrders(int dir)
{
  // Функция закрытия ордеров
        int i, total = OrdersTotal();   if (total<=0) return(true);
        int ticket[1000], nt=0;
      int Slip = 1000;
        nt=0;
        for (i=0; i<total; i++) 
        {       
                if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) return(false); 
                if (OrderType()==dir||dir<0 && (OrderSymbol()==Symbol()))
                { ticket[nt]=OrderTicket(); nt++; }
        }
        for (i=0; i<nt; i++)
        {       
                OrderSelect(ticket[i], SELECT_BY_TICKET);       
                if (OrderType()==OP_BUY) if (!OrderClose(ticket[i], OrderLots(), NormalizeDouble(OrderClosePrice(), Digits), Slip)) return(false);
                if (OrderType()==OP_SELL) if (!OrderClose(ticket[i], OrderLots(), NormalizeDouble(OrderClosePrice(), Digits), Slip)) return(false);
                if (OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
                        if (!OrderDelete(ticket[i])) return(false);
        }
        return(true);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   CalculateDay();
   for (int i = 0; i < COUNT_CONST; i++)
   {
      if (!isChoseR)
      {
         ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanSOpen[i]);
         if (isSopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
         else ButtonTextChange(0, "But"+i, 0);      
      }
      else
      {
         ObjectSetInteger(0,"But"+i,OBJPROP_STATE,isCanROpen[i]);
         if (isRopen[i] > 0) ButtonTextChange(0, "But"+i, 1);
         else ButtonTextChange(0, "But"+i, 0);       
      }
   }
      for(int i = 0; i < COUNT_CONST; i++)
      {
         if (MarketInfo(Symbol(), MODE_ASK) >= (rArr[i] - Диапазон*Point) && isRopen[i] == -1 && isCanROpen[i])
         {
            isRopen[i] = OpenOrder(OP_SELL);
            if (isRopen[i] != -1) isCanROpen[i] = 0;
         }
         
         if (MarketInfo(Symbol(), MODE_BID) <= (sArr[i] + Диапазон*Point) && isSopen[i] == -1 && isCanSOpen[i])
         {
            isSopen[i] = OpenOrder(OP_BUY);
            if (isSopen[i] != -1) isCanSOpen[i] = 0;
         }
         
         if(OrderSelect(isRopen[i], SELECT_BY_TICKET, MODE_TRADES) == true && isRopen[i] != -1)      
         {
            datetime ctm = OrderCloseTime();
            if (ctm > 0)
            {
               while(!CloseOrders(-1));
               countOfLots = 0;
               for(int cnt = 0; cnt < COUNT_CONST; cnt++)
               {
                  isRopen[cnt] = -1;
                  isSopen[cnt] = -1;
               }
            }
         }
         
         if(OrderSelect(isSopen[i], SELECT_BY_TICKET, MODE_TRADES) == true && isSopen[i] != -1)      
         {
            datetime ctm = OrderCloseTime();
            if (ctm > 0)
            {
               while(!CloseOrders(-1));
               countOfLots = 0;
               for(int cnt = 0; cnt < COUNT_CONST; cnt++)
               {
                  isRopen[cnt] = -1;
                  isSopen[cnt] = -1;
               }
            }
         }
      }
   //}
   //else Print("SymbolInfoTick() failed, error = ",GetLastError());


}
//+------------------------------------------------------------------+

string           InpName="Button";            // Имя кнопки
ENUM_BASE_CORNER InpCorner=CORNER_LEFT_UPPER; // Угол графика для привязки
string           InpFont="Arial";             // Шрифт
int              InpFontSize=10;              // Размер шрифта
color            InpColor=clrBlack;           // Цвет текста
color            InpBackColor=C'236,233,216'; // Цвет фона
color            InpBorderColor=clrNONE;      // Цвет границы
bool             InpState=false;              // Нажата/Отжата
bool             InpBack=false;               // Объект на заднем плане
bool             InpSelection=false;          // Выделить для перемещений
bool             InpHidden=true;              // Скрыт в списке объектов
long             InpZOrder=0;                 // Приоритет на нажатие мышью
//+------------------------------------------------------------------+
//| Создает кнопку                                                   |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // ID графика
                  const string            name="Button",            // имя кнопки
                  const int               sub_window=0,             // номер подокна
                  const int               x=0,                      // координата по оси X
                  const int               y=0,                      // координата по оси Y
                  const int               width=50,                 // ширина кнопки
                  const int               height=18,                // высота кнопки
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки
                  const string            text="Button",            // текст
                  const string            font="Arial",             // шрифт
                  const int               font_size=10,             // размер шрифта
                  const color             clr=clrBlack,             // цвет текста
                  const color             back_clr=C'236,233,216',  // цвет фона
                  const color             border_clr=clrNONE,       // цвет границы
                  const bool              state=false,              // нажата/отжата
                  const bool              back=false,               // на заднем плане
                  const bool              selection=false,          // выделить для перемещений
                  const bool              hidden=true,              // скрыт в списке объектов
                  const long              z_order=0)                // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- создадим кнопку
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": не удалось создать кнопку! Код ошибки = ",GetLastError());
      return(false);
     }
//--- установим координаты кнопки
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- установим размер кнопки
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- установим текст
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- установим шрифт текста
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- установим размер шрифта
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- установим цвет текста
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим цвет фона
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- установим цвет границы
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- переведем кнопку в заданное состояние
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- включим (true) или отключим (false) режим перемещения кнопки мышью
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);

ObjectSetInteger(chart_ID,name,OBJPROP_BACK,0);
   return(true);
  }
//+------------------------------------------------------------------+
//| Перемещает кнопку                                                |
//+------------------------------------------------------------------+
bool ButtonMove(const long   chart_ID=0,    // ID графика
                const string name="Button", // имя кнопки
                const int    x=0,           // координата по оси X
                const int    y=0)           // координата по оси Y
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- переместим кнопку
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": не удалось переместить X-координату кнопки! Код ошибки = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": не удалось переместить Y-координату кнопки! Код ошибки = ",GetLastError());
      return(false);
     }
//--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
//| Изменяет размер кнопки                                           |
//+------------------------------------------------------------------+
bool ButtonChangeSize(const long   chart_ID=0,    // ID графика
                      const string name="Button", // имя кнопки
                      const int    width=50,      // ширина кнопки
                      const int    height=18)     // высота кнопки
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- изменим размеры кнопки
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width))
     {
      Print(__FUNCTION__,
            ": не удалось изменить ширину кнопки! Код ошибки = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height))
     {
      Print(__FUNCTION__,
            ": не удалось изменить высоту кнопки! Код ошибки = ",GetLastError());
      return(false);
     }
//--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
//| Изменяет текст кнопки                                            |
//+------------------------------------------------------------------+
bool ButtonTextChange(const long   chart_ID=0,    // ID графика
                      const string name="Button", // имя кнопки
                      const string text="Text")   // текст
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- изменим текст объекта
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": не удалось изменить текст! Код ошибки = ",GetLastError());
      return(false);
     }
//--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
//| Удаляет кнопку                                                   |
//+------------------------------------------------------------------+
bool ButtonDelete(const long   chart_ID=0,    // ID графика
                  const string name="Button") // имя кнопки
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- удалим кнопку
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": не удалось удалить кнопку! Код ошибки = ",GetLastError());
      return(false);
     }
//--- успешное выполнение
   return(true);
  }