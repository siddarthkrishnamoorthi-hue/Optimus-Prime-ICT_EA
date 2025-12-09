//+------------------------------------------------------------------+
//|                                                OptimusPrime.mq5 |
//|                        Optimus Prime - ICT Expert Advisor v1.0 |
//|                                   EURUSD M15 Institutional EA |
//+------------------------------------------------------------------+
#property copyright "Heisenberg"
#property link      ""
#property version   "1.00"
#property description "Enterprise-grade ICT Expert Advisor for EURUSD"
#property description "Pure price action | Zero lagging indicators"
#property description "Institutional order flow | Military-grade risk management"
#property strict

//+------------------------------------------------------------------+
//| MODULE: Configuration - Input Parameters                         |
//+------------------------------------------------------------------+

//--- Category 1: Core Settings ---
input group "═══════════ CORE SETTINGS ═══════════"
input string    inp_SymbolSuffix = "";              // Symbol suffix/prefix (auto-detect if empty)
input int       inp_MagicNumber = 240324;            // Unique EA identifier
input bool      inp_VerboseDebug = false;            // Enable detailed logging
input string    inp_CommentPrefix = "OptimusPrime";  // Trade comment prefix

//--- Killzone Settings ---
input group "═══════════ KILLZONE SETTINGS ═══════════"
input bool      inp_EnableLondonKZ = true;           // Trade London session (07:00-10:00 UTC)
input bool      inp_EnableNewYorkKZ = true;          // Trade NY session (12:00-16:00 UTC)
input bool      inp_AllowOffKillzone = false;        // Allow trades outside killzones
input bool      inp_UsePowerHours = true;            // Prioritize first 30min of each session

//--- Timeframe Settings ---
input group "═══════════ TIMEFRAME SETTINGS ═══════════"
input ENUM_TIMEFRAMES inp_ExecutionTF = PERIOD_M15;  // Execution timeframe (M15 recommended)
input ENUM_TIMEFRAMES inp_ConfirmTF = PERIOD_H1;     // Confirmation timeframe
input ENUM_TIMEFRAMES inp_BiasTF = PERIOD_H4;        // Bias timeframe

//--- Category 2: Risk Management ---
input group "═══════════ RISK MANAGEMENT ═══════════"
input double    inp_RiskPerTrade = 1.0;              // Risk per trade (% of balance) [0.5-5.0]
input double    inp_MaxDailyRiskPercent = 3.0;       // Max daily risk (%) [2.0-10.0]
input int       inp_MaxTradesPerDay = 3;             // Max trades per day [1-10]
input int       inp_MaxConsecutiveLosses = 3;        // Trigger cooldown after N losses [2-5]
input int       inp_CooldownPeriod = 240;            // Cooldown duration (minutes) [60-480]
input double    inp_MaxDrawdownPercent = 5.0;        // Emergency stop drawdown (%) [5.0-25.0]
input double    inp_MaxMarginUsagePercent = 40.0;    // Max margin utilization (%) [20-80]
input int       inp_MaxRiskPips = 50;                // Hard cap on SL distance (pips) [30-100]

//--- Category 3: Rolling True Range (Volatility) ---
input group "═══════════ ROLLING TRUE RANGE ═══════════"
input int       inp_RollingTR_Period_M15 = 14;       // M15 TR period [8-30]
input int       inp_RollingTR_Period_H1 = 10;        // H1 TR period [6-20]
input int       inp_RollingTR_Period_H4 = 8;         // H4 TR period [5-15]

//--- Category 4: Swing Structure ---
input group "═══════════ SWING STRUCTURE ═══════════"
input int       inp_SwingWindow = 5;                 // Swing detection bars each side [3-10]
input int       inp_SwingLookback = 20;              // Bars to scan for swings [10-50]

//--- Category 5: Break of Structure (BOS) ---
input group "═══════════ BREAK OF STRUCTURE ═══════════"
input double    inp_BOS_MinBreak_Factor = 0.2;       // Min break size (x rolling_TR) [0.1-0.5]
input int       inp_BOS_Lookback = 3;                // Swings to compare [2-5]

//--- Category 6: Liquidity ---
input group "═══════════ LIQUIDITY ═══════════"
input int       inp_LiqPool_Range_Pips = 15;         // Liquidity pool range (pips) [8-25]
input double    inp_LS_WickFactor = 0.3;             // Sweep wick extension (x TR) [0.2-0.5]
input double    inp_LS_MinWick = 0.5;                // Min sweep wick size (x TR) [0.3-0.8]
input double    inp_LS_BodyFactor = 0.6;             // Rejection candle body (x TR) [0.4-0.8]
input int       inp_LS_ValidityBars = 5;             // Sweep validity period (bars) [3-10]

//--- Category 7: Fair Value Gap (FVG) ---
input group "═══════════ FAIR VALUE GAP ═══════════"
input double    inp_FVG_MinFactor = 0.4;             // Min gap size (x rolling_TR) [0.3-0.8]
input double    inp_FVG_MaxFactor = 2.5;             // Max gap size (x rolling_TR) [1.5-4.0]
input double    inp_ImpulseBodyFactor = 0.7;         // Impulse candle body (x TR) [0.5-0.9]

//--- Category 8: Order Block (OB) ---
input group "═══════════ ORDER BLOCK ═══════════"
input double    inp_OB_MinBodyFactor = 0.65;         // Min OB candle body (x TR) [0.5-0.8]
input int       inp_ImpulseCandles = 3;              // Required impulse candles [2-5]
input double    inp_ImpulseMinMove = 1.5;            // Min impulse move (x TR) [1.0-3.0]
input double    inp_OB_MaxRangeFactor = 0.8;         // Max OB range (x TR) [0.5-1.2]

//--- Category 9: Confluence ---
input group "═══════════ CONFLUENCE ═══════════"
input double    inp_Confluence_Radius = 0.4;         // FVG/OB overlap radius (x TR) [0.2-0.6]
input int       inp_Min_Confluence_Score = 4;        // Min score to enter [3-6]

//--- Category 10: Entry & Execution ---
input group "═══════════ ENTRY & EXECUTION ═══════════"
input bool      inp_RequireRetrace = true;           // Wait for price to enter zone
input double    inp_MaxSlippagePips = 2.0;           // Max slippage (market orders) [1.0-5.0]
input int       inp_OrderExpiration_Hours = 4;       // Limit order expiration [2-12]

//--- Category 11: Stop Loss ---
input group "═══════════ STOP LOSS ═══════════"
input double    inp_SL_Buffer = 0.3;                 // SL buffer below sweep (x TR) [0.2-0.6]
input double    inp_SL_MaxATR_Multiple = 2.0;        // Max SL distance (x TR) [1.5-3.0]

//--- Category 12: Take Profit ---
input group "═══════════ TAKE PROFIT ═══════════"
input double    inp_TP1_RR = 1.5;                    // TP1 risk:reward [1.0-2.5]
input double    inp_TP2_RR = 3.0;                    // TP2 risk:reward [2.0-5.0]
input double    inp_TP3_RR = 5.0;                    // TP3 risk:reward (0=disabled) [0, 4.0-8.0]
input int       inp_TP1_ClosePercent = 40;           // % to close at TP1 [20-60]
input int       inp_TP2_ClosePercent = 40;           // % to close at TP2 [20-60]

//--- Category 13: Trailing Stop ---
input group "═══════════ TRAILING STOP ═══════════"
input bool      inp_UseTrailingStop = true;          // Enable trailing stop
input double    inp_TrailActivationR = 1.5;          // Activate at profit (R) [1.0-2.5]
input double    inp_TrailDistance_ATR = 1.0;         // Trail distance (x TR) [0.5-2.0]
input int       inp_TrailStep_Pips = 5;              // Min SL move increment [3-10]

//--- Category 14: Market Filters ---
input group "═══════════ MARKET FILTERS ═══════════"
input double    inp_SpreadMaxPips = 1.5;             // Max spread (pips) [0.8-3.0]
input double    inp_VolFilterMin = 0.3;              // Min volatility ratio [0.2-0.5]
input double    inp_VolFilterMax = 3.0;              // Max volatility ratio [2.0-5.0]
input bool      inp_NewsFilterEnabled = false;       // Enable news blackout
input int       inp_NewsBlackoutMinutes = 30;        // Minutes before/after news [15-60]

//--- Category 15: Commission & Costs ---
input group "═══════════ COMMISSION & COSTS ═══════════"
input double    inp_CommissionPerLot = 7.0;          // Round-trip commission ($/lot) [0-15]

//+------------------------------------------------------------------+
//| MODULE: Global Constants                                         |
//+------------------------------------------------------------------+

#define MAGIC_NUMBER inp_MagicNumber
#define EA_NAME "OptimusPrime"
#define EA_VERSION "1.0"

// Killzone times (UTC)
#define LONDON_START_HOUR 7
#define LONDON_START_MIN 0
#define LONDON_END_HOUR 10
#define LONDON_END_MIN 0

#define NY_START_HOUR 12
#define NY_START_MIN 0
#define NY_END_HOUR 16
#define NY_END_MIN 0

// IST offset (UTC + 5:30)
#define IST_OFFSET_SECONDS 19800

//+------------------------------------------------------------------+
//| MODULE: Enumeration Types                                        |
//+------------------------------------------------------------------+

enum ENUM_BIAS {
    BIAS_NEUTRAL,
    BIAS_BULLISH,
    BIAS_BEARISH
};

enum ENUM_SETUP_TYPE {
    SETUP_NONE,
    SETUP_FVG_BULLISH,
    SETUP_FVG_BEARISH,
    SETUP_OB_BULLISH,
    SETUP_OB_BEARISH,
    SETUP_CONFLUENCE_BULLISH,
    SETUP_CONFLUENCE_BEARISH
};

enum ENUM_TRADE_DIRECTION {
    TRADE_BUY,
    TRADE_SELL
};

//+------------------------------------------------------------------+
//| MODULE: Data Structures                                          |
//+------------------------------------------------------------------+

// Swing point structure
struct SwingPoint {
    datetime time;
    double price;
    int bar_index;
    int touches;
};

// Fair Value Gap structure
struct FVG_Data {
    bool valid;
    double high;
    double low;
    double mid;
    double size;
    datetime time_detected;
    int bars_ago;
};

// Order Block structure
struct OrderBlock {
    bool valid;
    double high;
    double low;
    double mid;
    double entry_level;
    datetime time_detected;
    int ob_candle_index;
};

// Liquidity Sweep structure
struct LiquiditySweep {
    bool detected;
    double sweep_price;
    int candle_index;
    int bars_since_sweep;
};

// Trade Record structure
struct TradeRecord {
    datetime timestamp_utc;
    string symbol;
    ENUM_TRADE_DIRECTION direction;
    ENUM_SETUP_TYPE setup_type;
    double entry_price;
    double sl_price;
    double tp1_price;
    double tp2_price;
    double tp3_price;
    double lot_size;
    double risk_pips;
    double risk_amount;
    double risk_percent;
    double rolling_TR_M15;
    double rolling_TR_H1;
    double rolling_TR_H4;
    ENUM_BIAS htf_bias;
    bool bos_confirmed;
    double liquidity_sweep_price;
    double fvg_low;
    double fvg_high;
    double fvg_mid;
    double fvg_size;
    double ob_low;
    double ob_high;
    double ob_mid;
    double ob_range;
    int confluence_score;
    bool in_London_KZ;
    bool in_NY_KZ;
    double spread_at_entry;
    double slippage_pips;
    ulong ticket_number;
    datetime fill_time;
    double fill_price;
    datetime close_time;
    double close_price;
    string close_reason;
    double gross_profit;
    double net_profit;
    double commission;
    double swap;
    double account_balance_before;
    double account_balance_after;
    double account_equity_before;
    double account_equity_after;
};

//+------------------------------------------------------------------+
//| MODULE: Global Variables                                         |
//+------------------------------------------------------------------+

// Symbol information
string g_symbol;
double g_point;
double g_tick_size;
double g_tick_value;
int g_digits;
double g_pip_value;

// Time management
datetime g_last_bar_time_M15;
datetime g_last_bar_time_H1;
datetime g_last_bar_time_H4;
datetime g_cooldown_until;

// Rolling True Range values
double g_rolling_TR_M15;
double g_rolling_TR_H1;
double g_rolling_TR_H4;

// Swing points (store last 3 for each TF)
SwingPoint g_swing_highs_M15[3];
SwingPoint g_swing_lows_M15[3];
SwingPoint g_swing_highs_H1[3];
SwingPoint g_swing_lows_H1[3];
SwingPoint g_swing_highs_H4[3];
SwingPoint g_swing_lows_H4[3];

// Higher timeframe bias
ENUM_BIAS g_HTF_bias;

// Current setups
FVG_Data g_fvg_bullish;
FVG_Data g_fvg_bearish;
OrderBlock g_ob_bullish;
OrderBlock g_ob_bearish;
LiquiditySweep g_liq_sweep_bullish;
LiquiditySweep g_liq_sweep_bearish;

// Daily tracking
int g_daily_trades;
double g_daily_risk_taken;
double g_daily_profit;
datetime g_last_daily_reset;

// Performance metrics
int g_total_trades;
int g_winning_trades;
int g_consecutive_wins;
int g_consecutive_losses;
int g_max_consecutive_wins;
int g_max_consecutive_losses;
double g_gross_profit;
double g_gross_loss;
double g_net_profit;
double g_max_drawdown;
double g_current_drawdown;
double g_peak_balance;

// Last known swing points for logging
double g_last_swing_high;
double g_last_swing_low;

// H1 confirmation flag
bool g_H1_confirmed;

// CSV logging
int g_csv_handle;
string g_csv_filename = "OptimusPrime_TradeLog.csv";

// Trading state
bool g_trading_allowed;
string g_last_rejection_reason;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("═══════════════════════════════════════════════════");
    Print("  Optimus Prime ICT Expert Advisor v", EA_VERSION);
    Print("  Initializing on ", Symbol(), " ", EnumToString(Period()));
    Print("═══════════════════════════════════════════════════");
    
    // Validate and setup symbol
    if(!InitializeSymbol()) {
        return INIT_FAILED;
    }
    
    // Initialize time tracking
    g_last_bar_time_M15 = 0;
    g_last_bar_time_H1 = 0;
    g_last_bar_time_H4 = 0;
    g_cooldown_until = 0;
    
    // Initialize rolling TR
    g_rolling_TR_M15 = 0;
    g_rolling_TR_H1 = 0;
    g_rolling_TR_H4 = 0;
    
    // Initialize bias
    g_HTF_bias = BIAS_NEUTRAL;
    
    // Initialize setups
    InitializeSetups();
    
    // Initialize daily tracking
    g_daily_trades = 0;
    g_daily_risk_taken = 0;
    g_daily_profit = 0;
    g_last_daily_reset = TimeCurrent();
    
    // Initialize performance metrics
    g_total_trades = 0;
    g_winning_trades = 0;
    g_consecutive_wins = 0;
    g_consecutive_losses = 0;
    g_max_consecutive_wins = 0;
    g_max_consecutive_losses = 0;
    g_gross_profit = 0;
    g_gross_loss = 0;
    g_net_profit = 0;
    g_max_drawdown = 0;
    g_current_drawdown = 0;
    g_peak_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    g_last_swing_high = 0;
    g_last_swing_low = 0;
    g_H1_confirmed = false;
    
    // Initialize trading state
    g_trading_allowed = true;
    g_last_rejection_reason = "";
    
    // Initialize CSV logging
    WriteCSVHeader();
    if(!InitializeCSVLog()) {
        Print("Warning: CSV logging initialization failed");
    }
    
    // Calculate initial rolling TR values
    UpdateRollingTR();
    
    Print("Initialization successful!");
    Print("Risk per trade: ", inp_RiskPerTrade, "%");
    Print("Max trades per day: ", inp_MaxTradesPerDay);
    Print("London KZ: ", inp_EnableLondonKZ ? "ENABLED" : "DISABLED");
    Print("New York KZ: ", inp_EnableNewYorkKZ ? "ENABLED" : "DISABLED");
    Print("═══════════════════════════════════════════════════");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("═══════════════════════════════════════════════════");
    Print("  Optimus Prime EA Shutting Down");
    Print("  Reason: ", GetUninitReasonText(reason));
    Print("═══════════════════════════════════════════════════");
    
    // Close CSV file if open
    if(g_csv_handle != INVALID_HANDLE) {
        FileClose(g_csv_handle);
    }
    
    // Clear chart objects if any
    Comment("");
    
    Print("Total trades executed: ", g_total_trades);
    Print("Win rate: ", g_total_trades > 0 ? DoubleToString(g_winning_trades * 100.0 / g_total_trades, 1) : "0", "%");
    Print("Net P/L: $", DoubleToString(g_net_profit, 2));
    Print("═══════════════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Light tick handler - delegate heavy work to bar close
    
    // Check for new M15 bar
    if(IsNewBar(inp_ExecutionTF, g_last_bar_time_M15)) {
        OnNewBarM15();
    }
    
    // Check for new H1 bar
    if(IsNewBar(inp_ConfirmTF, g_last_bar_time_H1)) {
        OnNewBarH1();
    }
    
    // Check for new H4 bar
    if(IsNewBar(inp_BiasTF, g_last_bar_time_H4)) {
        OnNewBarH4();
    }
    
    // Manage open trades (runs every tick)
    ManageOpenTrades();
    
    // Update chart display
    DisplayChartInfo();
}

//+------------------------------------------------------------------+
//| Initialize symbol information                                    |
//+------------------------------------------------------------------+
bool InitializeSymbol()
{
    // Get current symbol
    g_symbol = Symbol();
    
    // Validate EURUSD
    if(StringFind(g_symbol, "EURUSD") == -1 && StringFind(g_symbol, "eurusd") == -1) {
        Alert("ERROR: This EA is designed for EURUSD only!");
        Print("Current symbol: ", g_symbol);
        Print("Please attach to EURUSD chart (any suffix/prefix supported)");
        return false;
    }
    
    // Get symbol properties
    g_point = SymbolInfoDouble(g_symbol, SYMBOL_POINT);
    g_tick_size = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_SIZE);
    g_tick_value = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_VALUE);
    g_digits = (int)SymbolInfoInteger(g_symbol, SYMBOL_DIGITS);
    
    // Calculate pip value (handles 3 & 5 digit brokers)
    if(g_digits == 3 || g_digits == 5) {
        g_pip_value = g_point * 10; // 5-digit broker
    } else {
        g_pip_value = g_point; // 3-digit broker
    }
    
    Print("Symbol validated: ", g_symbol);
    Print("Digits: ", g_digits);
    Print("Point: ", g_point);
    Print("Pip value: ", g_pip_value);
    
    return true;
}

//+------------------------------------------------------------------+
//| Initialize setup structures                                       |
//+------------------------------------------------------------------+
void InitializeSetups()
{
    g_fvg_bullish.valid = false;
    g_fvg_bearish.valid = false;
    g_ob_bullish.valid = false;
    g_ob_bearish.valid = false;
    g_liq_sweep_bullish.detected = false;
    g_liq_sweep_bearish.detected = false;
    
    // Initialize swing arrays
    for(int i = 0; i < 3; i++) {
        g_swing_highs_M15[i].price = 0;
        g_swing_lows_M15[i].price = 0;
        g_swing_highs_H1[i].price = 0;
        g_swing_lows_H1[i].price = 0;
        g_swing_highs_H4[i].price = 0;
        g_swing_lows_H4[i].price = 0;
    }
}

//+------------------------------------------------------------------+
//| Initialize CSV log file                                          |
//+------------------------------------------------------------------+
bool InitializeCSVLog()
{
    // Create/open CSV file
    g_csv_handle = FileOpen(g_csv_filename, FILE_WRITE|FILE_READ|FILE_CSV|FILE_COMMON);
    
    if(g_csv_handle == INVALID_HANDLE) {
        Print("Failed to create CSV log file: ", GetLastError());
        return false;
    }
    
    // Check if file is new (empty)
    if(FileSize(g_csv_handle) == 0) {
        // Write header
        FileWrite(g_csv_handle,
            "timestamp_utc", "timestamp_ist", "symbol", "direction", "setup_type",
            "entry_price", "sl_price", "tp1_price", "tp2_price", "tp3_price",
            "lot_size", "risk_pips", "risk_amount", "risk_percent",
            "rolling_TR_M15", "rolling_TR_H1", "rolling_TR_H4",
            "HTF_bias", "BOS_confirmed", "liquidity_sweep_price",
            "fvg_low", "fvg_high", "fvg_mid", "fvg_size",
            "ob_low", "ob_high", "ob_mid", "ob_range",
            "confluence_score", "in_London_KZ", "in_NY_KZ",
            "spread_at_entry", "slippage_pips",
            "ticket_number", "fill_time", "fill_price",
            "close_time", "close_price", "close_reason",
            "gross_profit", "net_profit", "commission", "swap",
            "account_balance_before", "account_balance_after",
            "account_equity_before", "account_equity_after"
        );
    }
    
    FileClose(g_csv_handle);
    
    Print("CSV log initialized: ", g_csv_filename);
    return true;
}

//+------------------------------------------------------------------+
//| Check for new bar on specified timeframe                         |
//+------------------------------------------------------------------+
bool IsNewBar(ENUM_TIMEFRAMES timeframe, datetime &last_bar_time)
{
    datetime current_bar_time = iTime(g_symbol, timeframe, 0);
    
    if(current_bar_time != last_bar_time) {
        last_bar_time = current_bar_time;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Main logic - M15 bar close                                       |
//+------------------------------------------------------------------+
void OnNewBarM15()
{
    if(inp_VerboseDebug) {
        Print("[M15 BAR] New bar detected at ", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
    }
    
    // Update rolling TR for M15
    UpdateRollingTR();
    
    // Check daily reset
    CheckDailyReset();
    
    // Age and expire old FVGs and OBs
    CheckZoneExpiration();
    
    // Detect swing points on M15
    DetectSwings(inp_ExecutionTF, g_swing_highs_M15, g_swing_lows_M15);
    
    // Detect liquidity sweeps
    DetectLiquiditySweep();
    
    // Detect FVG patterns
    DetectFVG();
    
    // Detect Order Blocks
    DetectOrderBlock();
    
    // Validate and execute setups
    ValidateAndExecuteSetup();
}

//+------------------------------------------------------------------+
//| Check and expire old FVG/OB zones                                |
//+------------------------------------------------------------------+
void CheckZoneExpiration()
{
    datetime current_time = TimeCurrent();
    int max_age_bars = 20;  // Zones expire after 20 M15 bars (5 hours)
    int max_age_seconds = max_age_bars * 15 * 60;  // In seconds
    
    // Age bullish FVG
    if(g_fvg_bullish.valid) {
        g_fvg_bullish.bars_ago++;
        
        int age_seconds = (int)(current_time - g_fvg_bullish.time_detected);
        if(age_seconds > max_age_seconds) {
            g_fvg_bullish.valid = false;
            if(inp_VerboseDebug) Print("[FVG] Bullish FVG expired (age: ", g_fvg_bullish.bars_ago, " bars)");
        }
        
        // Check if price has already filled the gap (invalidates it)
        double current_price = SymbolInfoDouble(g_symbol, SYMBOL_BID);
        if(current_price < g_fvg_bullish.low) {
            g_fvg_bullish.valid = false;
            if(inp_VerboseDebug) Print("[FVG] Bullish FVG filled - invalidated");
        }
    }
    
    // Age bearish FVG
    if(g_fvg_bearish.valid) {
        g_fvg_bearish.bars_ago++;
        
        int age_seconds = (int)(current_time - g_fvg_bearish.time_detected);
        if(age_seconds > max_age_seconds) {
            g_fvg_bearish.valid = false;
            if(inp_VerboseDebug) Print("[FVG] Bearish FVG expired (age: ", g_fvg_bearish.bars_ago, " bars)");
        }
        
        // Check if price has already filled the gap
        double current_price = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
        if(current_price > g_fvg_bearish.high) {
            g_fvg_bearish.valid = false;
            if(inp_VerboseDebug) Print("[FVG] Bearish FVG filled - invalidated");
        }
    }
    
    // Age bullish OB
    if(g_ob_bullish.valid) {
        g_ob_bullish.bars_ago++;
        
        int age_seconds = (int)(current_time - g_ob_bullish.time_detected);
        if(age_seconds > max_age_seconds) {
            g_ob_bullish.valid = false;
            if(inp_VerboseDebug) Print("[OB] Bullish OB expired (age: ", g_ob_bullish.bars_ago, " bars)");
        }
        
        // Check if price has broken below the OB low (invalidates it)
        double current_price = SymbolInfoDouble(g_symbol, SYMBOL_BID);
        if(current_price < g_ob_bullish.low - g_rolling_TR_M15 * 0.5) {
            g_ob_bullish.valid = false;
            if(inp_VerboseDebug) Print("[OB] Bullish OB broken - invalidated");
        }
    }
    
    // Age bearish OB
    if(g_ob_bearish.valid) {
        g_ob_bearish.bars_ago++;
        
        int age_seconds = (int)(current_time - g_ob_bearish.time_detected);
        if(age_seconds > max_age_seconds) {
            g_ob_bearish.valid = false;
            if(inp_VerboseDebug) Print("[OB] Bearish OB expired (age: ", g_ob_bearish.bars_ago, " bars)");
        }
        
        // Check if price has broken above the OB high (invalidates it)
        double current_price = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
        if(current_price > g_ob_bearish.high + g_rolling_TR_M15 * 0.5) {
            g_ob_bearish.valid = false;
            if(inp_VerboseDebug) Print("[OB] Bearish OB broken - invalidated");
        }
    }
}

//+------------------------------------------------------------------+
//| H1 bar close handler                                             |
//+------------------------------------------------------------------+
void OnNewBarH1()
{
    if(inp_VerboseDebug) {
        Print("[H1 BAR] New bar detected at ", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
    }
    
    // Detect swing points on H1
    DetectSwings(inp_ConfirmTF, g_swing_highs_H1, g_swing_lows_H1);
    
    // Check H1 confirmation - look for alignment with bias
    CheckH1Confirmation();
}

//+------------------------------------------------------------------+
//| Check H1 confirmation - validate trend alignment                 |
//+------------------------------------------------------------------+
void CheckH1Confirmation()
{
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    if(CopyRates(g_symbol, inp_ConfirmTF, 0, 5, rates) < 5) {
        g_H1_confirmed = false;
        return;
    }
    
    // Check if H1 is making higher highs/higher lows for bullish
    // or lower highs/lower lows for bearish
    
    bool higher_high = rates[0].high > rates[1].high;
    bool higher_low = rates[0].low > rates[1].low;
    bool lower_high = rates[0].high < rates[1].high;
    bool lower_low = rates[0].low < rates[1].low;
    
    // Also check if price is above/below the swing structure
    double current_price = SymbolInfoDouble(g_symbol, SYMBOL_BID);
    
    if(g_HTF_bias == BIAS_BULLISH) {
        // For bullish, want H1 showing higher lows or bullish candle close
        if(higher_low || (rates[0].close > rates[0].open && rates[0].close > rates[1].close)) {
            g_H1_confirmed = true;
            if(inp_VerboseDebug) Print("[H1 CONFIRM] Bullish confirmation detected");
        } else {
            g_H1_confirmed = false;
        }
    } else if(g_HTF_bias == BIAS_BEARISH) {
        // For bearish, want H1 showing lower highs or bearish candle close
        if(lower_high || (rates[0].close < rates[0].open && rates[0].close < rates[1].close)) {
            g_H1_confirmed = true;
            if(inp_VerboseDebug) Print("[H1 CONFIRM] Bearish confirmation detected");
        } else {
            g_H1_confirmed = false;
        }
    } else {
        // Neutral bias - check for momentum
        g_H1_confirmed = (MathAbs(rates[0].close - rates[0].open) > g_rolling_TR_H1 * 0.3);
    }
}

//+------------------------------------------------------------------+
//| H4 bar close handler                                             |
//+------------------------------------------------------------------+
void OnNewBarH4()
{
    if(inp_VerboseDebug) {
        Print("[H4 BAR] New bar detected at ", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
    }
    
    // Detect swing points on H4
    DetectSwings(inp_BiasTF, g_swing_highs_H4, g_swing_lows_H4);
    
    // Detect Break of Structure for HTF bias
    DetectBOS();
}

//+------------------------------------------------------------------+
//| MODULE: Rolling True Range Calculation                           |
//+------------------------------------------------------------------+
void UpdateRollingTR()
{
    // Calculate M15 rolling TR
    g_rolling_TR_M15 = CalculateRollingTR(inp_ExecutionTF, inp_RollingTR_Period_M15);
    
    // Calculate H1 rolling TR
    g_rolling_TR_H1 = CalculateRollingTR(inp_ConfirmTF, inp_RollingTR_Period_H1);
    
    // Calculate H4 rolling TR
    g_rolling_TR_H4 = CalculateRollingTR(inp_BiasTF, inp_RollingTR_Period_H4);
    
    if(inp_VerboseDebug) {
        Print("[ROLLING TR] M15: ", DoubleToString(g_rolling_TR_M15, g_digits),
              " | H1: ", DoubleToString(g_rolling_TR_H1, g_digits),
              " | H4: ", DoubleToString(g_rolling_TR_H4, g_digits));
    }
}

//+------------------------------------------------------------------+
//| Calculate Rolling True Range for specified timeframe             |
//+------------------------------------------------------------------+
double CalculateRollingTR(ENUM_TIMEFRAMES timeframe, int period)
{
    if(period <= 0) return 0;
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    int copied = CopyRates(g_symbol, timeframe, 0, period + 1, rates);
    if(copied < period + 1) {
        Print("Error copying rates for TR calculation: ", GetLastError());
        return 0;
    }
    
    double tr_sum = 0;
    
    for(int i = 0; i < period; i++) {
        double high_low = rates[i].high - rates[i].low;
        double high_close = MathAbs(rates[i].high - rates[i+1].close);
        double low_close = MathAbs(rates[i].low - rates[i+1].close);
        
        double tr = MathMax(high_low, MathMax(high_close, low_close));
        tr_sum += tr;
    }
    
    return tr_sum / period;
}

//+------------------------------------------------------------------+
//| Detect swing highs and lows                                      |
//+------------------------------------------------------------------+
void DetectSwings(ENUM_TIMEFRAMES timeframe, SwingPoint &swing_highs[], SwingPoint &swing_lows[])
{
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    
    int bars_needed = inp_SwingLookback + inp_SwingWindow * 2;
    int copied = CopyRates(g_symbol, timeframe, 0, bars_needed, rates);
    
    if(copied < bars_needed) return;
    
    // Scan for swing highs
    for(int i = inp_SwingWindow; i < inp_SwingLookback; i++) {
        bool is_swing_high = true;
        
        // Check bars to the left and right
        for(int j = 1; j <= inp_SwingWindow; j++) {
            if(rates[i].high <= rates[i-j].high || rates[i].high <= rates[i+j].high) {
                is_swing_high = false;
                break;
            }
        }
        
        if(is_swing_high) {
            // Found a swing high - add to array
            AddSwingPoint(swing_highs, rates[i].time, rates[i].high, i);
            
            // Update last swing high for logging (use M15 swings)
            if(timeframe == inp_ExecutionTF) {
                g_last_swing_high = rates[i].high;
            }
            
            if(inp_VerboseDebug) {
                Print("[SWING] High detected on ", EnumToString(timeframe), 
                      " at ", DoubleToString(rates[i].high, g_digits),
                      " (bar ", i, ")");
            }
        }
    }
    
    // Scan for swing lows
    for(int i = inp_SwingWindow; i < inp_SwingLookback; i++) {
        bool is_swing_low = true;
        
        // Check bars to the left and right
        for(int j = 1; j <= inp_SwingWindow; j++) {
            if(rates[i].low >= rates[i-j].low || rates[i].low >= rates[i+j].low) {
                is_swing_low = false;
                break;
            }
        }
        
        if(is_swing_low) {
            // Found a swing low - add to array
            AddSwingPoint(swing_lows, rates[i].time, rates[i].low, i);
            
            // Update last swing low for logging (use M15 swings)
            if(timeframe == inp_ExecutionTF) {
                g_last_swing_low = rates[i].low;
            }
            
            if(inp_VerboseDebug) {
                Print("[SWING] Low detected on ", EnumToString(timeframe), 
                      " at ", DoubleToString(rates[i].low, g_digits),
                      " (bar ", i, ")");
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Add swing point to array (keep last 3)                           |
//+------------------------------------------------------------------+
void AddSwingPoint(SwingPoint &swing_array[], datetime time, double price, int bar_index)
{
    // Shift array down
    for(int i = 2; i > 0; i--) {
        swing_array[i] = swing_array[i-1];
    }
    
    // Add new swing point at index 0
    swing_array[0].time = time;
    swing_array[0].price = price;
    swing_array[0].bar_index = bar_index;
    swing_array[0].touches = 1;
}

//+------------------------------------------------------------------+
//| Detect Break of Structure on H4                                  |
//+------------------------------------------------------------------+
void DetectBOS()
{
    if(g_swing_highs_H4[0].price == 0 || g_swing_highs_H4[1].price == 0) return;
    if(g_swing_lows_H4[0].price == 0 || g_swing_lows_H4[1].price == 0) return;
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(g_symbol, inp_BiasTF, 0, 3, rates);
    if(copied < 3) return;
    
    double min_break = inp_BOS_MinBreak_Factor * g_rolling_TR_H4;
    
    // Check for bullish BOS (breaking above previous swing high)
    if(g_swing_highs_H4[0].price > g_swing_highs_H4[1].price + min_break) {
        if(rates[0].close > g_swing_highs_H4[0].price) {
            if(g_HTF_bias != BIAS_BULLISH) {
                g_HTF_bias = BIAS_BULLISH;
                if(inp_VerboseDebug) {
                    Print("[BOS] Bullish Break of Structure detected on H4");
                    Print("[BOS] Previous high: ", g_swing_highs_H4[1].price, 
                          " | New high: ", g_swing_highs_H4[0].price);
                }
            }
            return;
        }
    }
    
    // Check for bearish BOS (breaking below previous swing low)
    if(g_swing_lows_H4[0].price < g_swing_lows_H4[1].price - min_break) {
        if(rates[0].close < g_swing_lows_H4[0].price) {
            if(g_HTF_bias != BIAS_BEARISH) {
                g_HTF_bias = BIAS_BEARISH;
                if(inp_VerboseDebug) {
                    Print("[BOS] Bearish Break of Structure detected on H4");
                    Print("[BOS] Previous low: ", g_swing_lows_H4[1].price, 
                          " | New low: ", g_swing_lows_H4[0].price);
                }
            }
            return;
        }
    }
}

//+------------------------------------------------------------------+
//| Detect Liquidity Sweep                                           |
//+------------------------------------------------------------------+
void DetectLiquiditySweep()
{
    if(g_swing_lows_M15[0].price == 0 || g_swing_highs_M15[0].price == 0) return;
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(g_symbol, inp_ExecutionTF, 0, 3, rates);
    if(copied < 3) return;
    
    double candle_body = MathAbs(rates[1].close - rates[1].open);
    double candle_range = rates[1].high - rates[1].low;
    
    // Check for bullish liquidity sweep (sweep below, close above)
    double last_swing_low = g_swing_lows_M15[0].price;
    double sweep_threshold = last_swing_low - inp_LS_WickFactor * g_rolling_TR_M15;
    double min_wick = inp_LS_MinWick * g_rolling_TR_M15;
    double min_body = inp_LS_BodyFactor * g_rolling_TR_M15;
    
    if(rates[1].low < sweep_threshold &&                    // Wick swept below
       rates[1].close > last_swing_low &&                   // Close above swing low (rejection)
       (last_swing_low - rates[1].low) >= min_wick &&      // Sufficient wick size
       candle_body >= min_body &&                           // Strong body
       rates[1].close > rates[1].open) {                   // Bullish candle
        
        g_liq_sweep_bullish.detected = true;
        g_liq_sweep_bullish.sweep_price = rates[1].low;
        g_liq_sweep_bullish.candle_index = 1;
        g_liq_sweep_bullish.bars_since_sweep = 0;
        
        if(inp_VerboseDebug) {
            Print("[LIQUIDITY] Bullish sweep detected!");
            Print("[LIQUIDITY] Sweep low: ", rates[1].low, " | Swing low: ", last_swing_low);
            Print("[LIQUIDITY] Close: ", rates[1].close, " | Body: ", candle_body);
        }
    }
    
    // Check for bearish liquidity sweep (sweep above, close below)
    double last_swing_high = g_swing_highs_M15[0].price;
    sweep_threshold = last_swing_high + inp_LS_WickFactor * g_rolling_TR_M15;
    
    if(rates[1].high > sweep_threshold &&                   // Wick swept above
       rates[1].close < last_swing_high &&                  // Close below swing high (rejection)
       (rates[1].high - last_swing_high) >= min_wick &&    // Sufficient wick size
       candle_body >= min_body &&                           // Strong body
       rates[1].close < rates[1].open) {                   // Bearish candle
        
        g_liq_sweep_bearish.detected = true;
        g_liq_sweep_bearish.sweep_price = rates[1].high;
        g_liq_sweep_bearish.candle_index = 1;
        g_liq_sweep_bearish.bars_since_sweep = 0;
        
        if(inp_VerboseDebug) {
            Print("[LIQUIDITY] Bearish sweep detected!");
            Print("[LIQUIDITY] Sweep high: ", rates[1].high, " | Swing high: ", last_swing_high);
            Print("[LIQUIDITY] Close: ", rates[1].close, " | Body: ", candle_body);
        }
    }
    
    // Age existing sweeps
    if(g_liq_sweep_bullish.detected) {
        g_liq_sweep_bullish.bars_since_sweep++;
        if(g_liq_sweep_bullish.bars_since_sweep > inp_LS_ValidityBars) {
            g_liq_sweep_bullish.detected = false;
        }
    }
    
    if(g_liq_sweep_bearish.detected) {
        g_liq_sweep_bearish.bars_since_sweep++;
        if(g_liq_sweep_bearish.bars_since_sweep > inp_LS_ValidityBars) {
            g_liq_sweep_bearish.detected = false;
        }
    }
}

//+------------------------------------------------------------------+
//| Detect Fair Value Gap (FVG)                                      |
//+------------------------------------------------------------------+
void DetectFVG()
{
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(g_symbol, inp_ExecutionTF, 0, 5, rates);
    if(copied < 5) return;
    
    // Bullish FVG: Low[0] > High[2] (gap between candle C and candle A)
    // Candle A = rates[2], Candle B = rates[1] (impulse), Candle C = rates[0]
    
    double fvg_size_bullish = rates[0].low - rates[2].high;
    double candle_b_body = MathAbs(rates[1].close - rates[1].open);
    double candle_b_range = rates[1].high - rates[1].low;
    
    // Check bullish FVG
    if(fvg_size_bullish > 0) {  // Gap exists
        double min_fvg = inp_FVG_MinFactor * g_rolling_TR_M15;
        double max_fvg = inp_FVG_MaxFactor * g_rolling_TR_M15;
        double min_impulse_body = inp_ImpulseBodyFactor * g_rolling_TR_M15;
        
        if(fvg_size_bullish >= min_fvg && 
           fvg_size_bullish <= max_fvg &&
           candle_b_body >= min_impulse_body &&
           rates[1].close > rates[1].open) {  // Impulse is bullish
            
            g_fvg_bullish.valid = true;
            g_fvg_bullish.high = rates[0].low;
            g_fvg_bullish.low = rates[2].high;
            g_fvg_bullish.mid = (g_fvg_bullish.high + g_fvg_bullish.low) / 2;
            g_fvg_bullish.size = fvg_size_bullish;
            g_fvg_bullish.time_detected = TimeCurrent();
            g_fvg_bullish.bars_ago = 0;
            
            if(inp_VerboseDebug) {
                Print("[FVG] Bullish FVG detected!");
                Print("[FVG] High: ", g_fvg_bullish.high, " | Low: ", g_fvg_bullish.low);
                Print("[FVG] Size: ", fvg_size_bullish, " (", 
                      DoubleToString(fvg_size_bullish / g_rolling_TR_M15, 2), "x TR)");
            }
        }
    }
    
    // Bearish FVG: High[0] < Low[2]
    double fvg_size_bearish = rates[2].low - rates[0].high;
    
    // Check bearish FVG
    if(fvg_size_bearish > 0) {  // Gap exists
        double min_fvg = inp_FVG_MinFactor * g_rolling_TR_M15;
        double max_fvg = inp_FVG_MaxFactor * g_rolling_TR_M15;
        double min_impulse_body = inp_ImpulseBodyFactor * g_rolling_TR_M15;
        
        if(fvg_size_bearish >= min_fvg && 
           fvg_size_bearish <= max_fvg &&
           candle_b_body >= min_impulse_body &&
           rates[1].close < rates[1].open) {  // Impulse is bearish
            
            g_fvg_bearish.valid = true;
            g_fvg_bearish.high = rates[2].low;
            g_fvg_bearish.low = rates[0].high;
            g_fvg_bearish.mid = (g_fvg_bearish.high + g_fvg_bearish.low) / 2;
            g_fvg_bearish.size = fvg_size_bearish;
            g_fvg_bearish.time_detected = TimeCurrent();
            g_fvg_bearish.bars_ago = 0;
            
            if(inp_VerboseDebug) {
                Print("[FVG] Bearish FVG detected!");
                Print("[FVG] High: ", g_fvg_bearish.high, " | Low: ", g_fvg_bearish.low);
                Print("[FVG] Size: ", fvg_size_bearish, " (", 
                      DoubleToString(fvg_size_bearish / g_rolling_TR_M15, 2), "x TR)");
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Detect Order Block (OB)                                          |
//+------------------------------------------------------------------+
void DetectOrderBlock()
{
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copied = CopyRates(g_symbol, inp_ExecutionTF, 0, 15, rates);
    if(copied < 15) return;
    
    // Search for bullish OB (last bearish candle before bullish impulse)
    for(int i = 1; i < 10; i++) {
        // Check if this is a strong bearish candle
        double ob_body = rates[i].open - rates[i].close;  // Bearish body
        double ob_range = rates[i].high - rates[i].low;
        double min_ob_body = inp_OB_MinBodyFactor * g_rolling_TR_M15;
        
        if(ob_body > 0 &&  // Bearish candle
           ob_body >= min_ob_body &&
           ob_body / ob_range >= 0.7) {  // Full-bodied (wicks < 30%)
            
            // Check for bullish impulse after this candle
            bool impulse_found = true;
            double cumulative_move = 0;
            
            for(int j = 0; j < inp_ImpulseCandles && (i - j - 1) >= 0; j++) {
                int candle_idx = i - j - 1;
                double impulse_body = rates[candle_idx].close - rates[candle_idx].open;
                double min_impulse = inp_ImpulseBodyFactor * g_rolling_TR_M15;
                
                if(impulse_body <= 0 || impulse_body < min_impulse) {
                    impulse_found = false;
                    break;
                }
                
                cumulative_move += impulse_body;
            }
            
            double min_move = inp_ImpulseMinMove * g_rolling_TR_M15;
            
            if(impulse_found && cumulative_move >= min_move) {
                // Valid bullish OB found
                double max_ob_range = inp_OB_MaxRangeFactor * g_rolling_TR_M15;
                
                if(ob_range <= max_ob_range) {
                    g_ob_bullish.valid = true;
                    g_ob_bullish.high = rates[i].high;
                    g_ob_bullish.low = rates[i].low;
                    g_ob_bullish.mid = (g_ob_bullish.high + g_ob_bullish.low) / 2;
                    g_ob_bullish.entry_level = g_ob_bullish.high - 0.25 * (g_ob_bullish.high - g_ob_bullish.low);
                    g_ob_bullish.time_detected = TimeCurrent();
                    g_ob_bullish.ob_candle_index = i;
                    g_ob_bullish.bars_ago = 0;  // Reset age counter
                    
                    if(inp_VerboseDebug) {
                        Print("[OB] Bullish Order Block detected at bar ", i);
                        Print("[OB] High: ", g_ob_bullish.high, " | Low: ", g_ob_bullish.low);
                        Print("[OB] Entry level: ", g_ob_bullish.entry_level);
                    }
                    
                    break;  // Found valid OB
                }
            }
        }
    }
    
    // Search for bearish OB (last bullish candle before bearish impulse)
    for(int i = 1; i < 10; i++) {
        // Check if this is a strong bullish candle
        double ob_body = rates[i].close - rates[i].open;  // Bullish body
        double ob_range = rates[i].high - rates[i].low;
        double min_ob_body = inp_OB_MinBodyFactor * g_rolling_TR_M15;
        
        if(ob_body > 0 &&  // Bullish candle
           ob_body >= min_ob_body &&
           ob_body / ob_range >= 0.7) {  // Full-bodied
            
            // Check for bearish impulse after this candle
            bool impulse_found = true;
            double cumulative_move = 0;
            
            for(int j = 0; j < inp_ImpulseCandles && (i - j - 1) >= 0; j++) {
                int candle_idx = i - j - 1;
                double impulse_body = rates[candle_idx].open - rates[candle_idx].close;
                double min_impulse = inp_ImpulseBodyFactor * g_rolling_TR_M15;
                
                if(impulse_body <= 0 || impulse_body < min_impulse) {
                    impulse_found = false;
                    break;
                }
                
                cumulative_move += impulse_body;
            }
            
            double min_move = inp_ImpulseMinMove * g_rolling_TR_M15;
            
            if(impulse_found && cumulative_move >= min_move) {
                // Valid bearish OB found
                double max_ob_range = inp_OB_MaxRangeFactor * g_rolling_TR_M15;
                
                if(ob_range <= max_ob_range) {
                    g_ob_bearish.valid = true;
                    g_ob_bearish.high = rates[i].high;
                    g_ob_bearish.low = rates[i].low;
                    g_ob_bearish.mid = (g_ob_bearish.high + g_ob_bearish.low) / 2;
                    g_ob_bearish.entry_level = g_ob_bearish.low + 0.25 * (g_ob_bearish.high - g_ob_bearish.low);
                    g_ob_bearish.time_detected = TimeCurrent();
                    g_ob_bearish.ob_candle_index = i;
                    g_ob_bearish.bars_ago = 0;  // Reset age counter
                    
                    if(inp_VerboseDebug) {
                        Print("[OB] Bearish Order Block detected at bar ", i);
                        Print("[OB] High: ", g_ob_bearish.high, " | Low: ", g_ob_bearish.low);
                        Print("[OB] Entry level: ", g_ob_bearish.entry_level);
                    }
                    
                    break;  // Found valid OB
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Validate and execute trading setup                               |
//+------------------------------------------------------------------+
void ValidateAndExecuteSetup()
{
    // Pre-flight checks
    if(!g_trading_allowed) {
        if(inp_VerboseDebug) Print("[SETUP] Trading not allowed");
        return;
    }
    
    // Check cooldown
    if(TimeCurrent() < g_cooldown_until) {
        if(inp_VerboseDebug) {
            Print("[SETUP] In cooldown period until ", TimeToString(g_cooldown_until));
        }
        return;
    }
    
    // Check daily limits
    if(!CheckDailyLimits()) {
        return;
    }
    
    // Check killzone
    if(!IsInKillzone()) {
        if(inp_VerboseDebug) Print("[SETUP] Not in killzone");
        return;
    }
    
    // Check spread
    if(!CheckSpread()) {
        return;
    }
    
    // Check volatility
    if(!CheckVolatility()) {
        return;
    }
    
    // Check for existing positions
    if(CountOpenPositions() > 0) {
        if(inp_VerboseDebug) Print("[SETUP] Already have open position");
        return;
    }
    
    // Calculate confluence for bullish setup
    if(g_HTF_bias == BIAS_BULLISH || g_HTF_bias == BIAS_NEUTRAL) {
        int bull_confluence = CalculateConfluence(true);
        
        if(bull_confluence >= inp_Min_Confluence_Score) {
            if(inp_VerboseDebug) {
                Print("[SETUP] Bullish setup validated! Confluence: ", bull_confluence);
            }
            
            // Execute buy setup
            ExecuteBuySetup(bull_confluence);
            return;
        }
    }
    
    // Calculate confluence for bearish setup
    if(g_HTF_bias == BIAS_BEARISH || g_HTF_bias == BIAS_NEUTRAL) {
        int bear_confluence = CalculateConfluence(false);
        
        if(bear_confluence >= inp_Min_Confluence_Score) {
            if(inp_VerboseDebug) {
                Print("[SETUP] Bearish setup validated! Confluence: ", bear_confluence);
            }
            
            // Execute sell setup
            ExecuteSellSetup(bear_confluence);
            return;
        }
    }
}

//+------------------------------------------------------------------+
//| Calculate confluence score                                       |
//+------------------------------------------------------------------+
int CalculateConfluence(bool is_bullish)
{
    int score = 0;
    
    if(is_bullish) {
        // FVG + OB overlap (3 points for strong confluence)
        if(g_fvg_bullish.valid && g_ob_bullish.valid) {
            double distance = MathAbs(g_fvg_bullish.mid - g_ob_bullish.mid);
            double confluence_radius = inp_Confluence_Radius * g_rolling_TR_M15;
            
            if(distance <= confluence_radius) {
                score += 3;
                if(inp_VerboseDebug) Print("[CONFLUENCE] FVG+OB overlap: +3");
            }
        } else if(g_fvg_bullish.valid || g_ob_bullish.valid) {
            score += 1;  // At least one zone present
            if(inp_VerboseDebug) Print("[CONFLUENCE] Single zone: +1");
        }
        
        // Liquidity sweep (2 points)
        if(g_liq_sweep_bullish.detected) {
            score += 2;
            if(inp_VerboseDebug) Print("[CONFLUENCE] Liquidity sweep: +2");
        }
        
        // Swing structure alignment (1 point)
        if(g_swing_lows_M15[0].price > 0 && g_swing_lows_M15[0].touches >= 2) {
            score += 1;
            if(inp_VerboseDebug) Print("[CONFLUENCE] Swing structure: +1");
        }
        
        // Killzone power hour boost (1 point)
        if(inp_UsePowerHours && IsInPowerHour()) {
            score += 1;
            if(inp_VerboseDebug) Print("[CONFLUENCE] Power hour: +1");
        }
        
        // H1 confirmation (2 points for multi-timeframe alignment)
        if(g_H1_confirmed) {
            score += 2;
            if(inp_VerboseDebug) Print("[CONFLUENCE] H1 confirmation: +2");
        }
        
    } else {  // Bearish
        // FVG + OB overlap
        if(g_fvg_bearish.valid && g_ob_bearish.valid) {
            double distance = MathAbs(g_fvg_bearish.mid - g_ob_bearish.mid);
            double confluence_radius = inp_Confluence_Radius * g_rolling_TR_M15;
            
            if(distance <= confluence_radius) {
                score += 3;
                if(inp_VerboseDebug) Print("[CONFLUENCE] FVG+OB overlap: +3");
            }
        } else if(g_fvg_bearish.valid || g_ob_bearish.valid) {
            score += 1;
            if(inp_VerboseDebug) Print("[CONFLUENCE] Single zone: +1");
        }
        
        // Liquidity sweep
        if(g_liq_sweep_bearish.detected) {
            score += 2;
            if(inp_VerboseDebug) Print("[CONFLUENCE] Liquidity sweep: +2");
        }
        
        // Swing structure alignment
        if(g_swing_highs_M15[0].price > 0 && g_swing_highs_M15[0].touches >= 2) {
            score += 1;
            if(inp_VerboseDebug) Print("[CONFLUENCE] Swing structure: +1");
        }
        
        // Killzone power hour boost
        if(inp_UsePowerHours && IsInPowerHour()) {
            score += 1;
            if(inp_VerboseDebug) Print("[CONFLUENCE] Power hour: +1");
        }
        
        // H1 confirmation (2 points for multi-timeframe alignment)
        if(g_H1_confirmed) {
            score += 2;
            if(inp_VerboseDebug) Print("[CONFLUENCE] H1 confirmation: +2");
        }
    }
    
    return score;
}

//+------------------------------------------------------------------+
//| Execute buy setup                                                |
//+------------------------------------------------------------------+
void ExecuteBuySetup(int confluence_score)
{
    // Determine entry price (conservative - lowest of FVG/OB zones)
    double entry_price = 0;
    
    if(g_fvg_bullish.valid && g_ob_bullish.valid) {
        double fvg_entry = g_fvg_bullish.low + 0.25 * g_fvg_bullish.size;  // 25% into FVG
        entry_price = MathMin(fvg_entry, g_ob_bullish.entry_level);
    } else if(g_fvg_bullish.valid) {
        entry_price = g_fvg_bullish.low + 0.25 * g_fvg_bullish.size;
    } else if(g_ob_bullish.valid) {
        entry_price = g_ob_bullish.entry_level;
    } else {
        if(inp_VerboseDebug) Print("[ENTRY] No valid entry zone");
        return;
    }
    
    // Calculate stop loss
    double sl_price;
    if(g_liq_sweep_bullish.detected) {
        sl_price = g_liq_sweep_bullish.sweep_price - inp_SL_Buffer * g_rolling_TR_M15;
    } else {
        double zone_low = 0;
        if(g_fvg_bullish.valid && g_ob_bullish.valid) {
            zone_low = MathMin(g_fvg_bullish.low, g_ob_bullish.low);
        } else if(g_fvg_bullish.valid) {
            zone_low = g_fvg_bullish.low;
        } else {
            zone_low = g_ob_bullish.low;
        }
        sl_price = zone_low - inp_SL_Buffer * g_rolling_TR_M15;
    }
    
    // Validate SL distance
    double risk_distance = entry_price - sl_price;
    double risk_pips = risk_distance / g_pip_value;
    double max_sl = inp_SL_MaxATR_Multiple * g_rolling_TR_M15;
    
    if(risk_pips > inp_MaxRiskPips || risk_distance > max_sl) {
        g_last_rejection_reason = "SL too wide: " + DoubleToString(risk_pips, 1) + " pips";
        if(inp_VerboseDebug) Print("[ENTRY] ", g_last_rejection_reason);
        return;
    }
    
    // Calculate position size
    double lot_size = CalculatePositionSize(risk_distance);
    if(lot_size <= 0) {
        g_last_rejection_reason = "Invalid lot size calculation";
        if(inp_VerboseDebug) Print("[ENTRY] ", g_last_rejection_reason);
        return;
    }
    
    // Calculate take profits
    double tp1_price = entry_price + inp_TP1_RR * risk_distance;
    double tp2_price = entry_price + inp_TP2_RR * risk_distance;
    double tp3_price = (inp_TP3_RR > 0) ? entry_price + inp_TP3_RR * risk_distance : 0;
    
    // Place order
    bool order_placed = false;
    
    if(inp_RequireRetrace) {
        // Wait for price to retrace into zone
        double current_price = SymbolInfoDouble(g_symbol, SYMBOL_BID);
        if(current_price <= entry_price) {
            // Price already in zone - use market order
            order_placed = PlaceMarketOrder(ORDER_TYPE_BUY, lot_size, sl_price, tp1_price, confluence_score);
        } else {
            // Place limit order
            order_placed = PlaceLimitOrder(ORDER_TYPE_BUY_LIMIT, lot_size, entry_price, sl_price, tp1_price, confluence_score);
        }
    } else {
        // Immediate market order
        order_placed = PlaceMarketOrder(ORDER_TYPE_BUY, lot_size, sl_price, tp1_price, confluence_score);
    }
    
    if(order_placed) {
        g_daily_trades++;
        g_daily_risk_taken += CalculateRiskAmount(lot_size, risk_distance);
    }
}

//+------------------------------------------------------------------+
//| Execute sell setup                                               |
//+------------------------------------------------------------------+
void ExecuteSellSetup(int confluence_score)
{
    // Determine entry price (conservative - highest of FVG/OB zones)
    double entry_price = 0;
    
    if(g_fvg_bearish.valid && g_ob_bearish.valid) {
        double fvg_entry = g_fvg_bearish.high - 0.25 * g_fvg_bearish.size;  // 25% into FVG
        entry_price = MathMax(fvg_entry, g_ob_bearish.entry_level);
    } else if(g_fvg_bearish.valid) {
        entry_price = g_fvg_bearish.high - 0.25 * g_fvg_bearish.size;
    } else if(g_ob_bearish.valid) {
        entry_price = g_ob_bearish.entry_level;
    } else {
        if(inp_VerboseDebug) Print("[ENTRY] No valid entry zone");
        return;
    }
    
    // Calculate stop loss
    double sl_price;
    if(g_liq_sweep_bearish.detected) {
        sl_price = g_liq_sweep_bearish.sweep_price + inp_SL_Buffer * g_rolling_TR_M15;
    } else {
        double zone_high = 0;
        if(g_fvg_bearish.valid && g_ob_bearish.valid) {
            zone_high = MathMax(g_fvg_bearish.high, g_ob_bearish.high);
        } else if(g_fvg_bearish.valid) {
            zone_high = g_fvg_bearish.high;
        } else {
            zone_high = g_ob_bearish.high;
        }
        sl_price = zone_high + inp_SL_Buffer * g_rolling_TR_M15;
    }
    
    // Validate SL distance
    double risk_distance = sl_price - entry_price;
    double risk_pips = risk_distance / g_pip_value;
    double max_sl = inp_SL_MaxATR_Multiple * g_rolling_TR_M15;
    
    if(risk_pips > inp_MaxRiskPips || risk_distance > max_sl) {
        g_last_rejection_reason = "SL too wide: " + DoubleToString(risk_pips, 1) + " pips";
        if(inp_VerboseDebug) Print("[ENTRY] ", g_last_rejection_reason);
        return;
    }
    
    // Calculate position size
    double lot_size = CalculatePositionSize(risk_distance);
    if(lot_size <= 0) {
        g_last_rejection_reason = "Invalid lot size calculation";
        if(inp_VerboseDebug) Print("[ENTRY] ", g_last_rejection_reason);
        return;
    }
    
    // Calculate take profits
    double tp1_price = entry_price - inp_TP1_RR * risk_distance;
    double tp2_price = entry_price - inp_TP2_RR * risk_distance;
    double tp3_price = (inp_TP3_RR > 0) ? entry_price - inp_TP3_RR * risk_distance : 0;
    
    // Place order
    bool order_placed = false;
    
    if(inp_RequireRetrace) {
        double current_price = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
        if(current_price >= entry_price) {
            // Price already in zone
            order_placed = PlaceMarketOrder(ORDER_TYPE_SELL, lot_size, sl_price, tp1_price, confluence_score);
        } else {
            // Place limit order
            order_placed = PlaceLimitOrder(ORDER_TYPE_SELL_LIMIT, lot_size, entry_price, sl_price, tp1_price, confluence_score);
        }
    } else {
        order_placed = PlaceMarketOrder(ORDER_TYPE_SELL, lot_size, sl_price, tp1_price, confluence_score);
    }
    
    if(order_placed) {
        g_daily_trades++;
        g_daily_risk_taken += CalculateRiskAmount(lot_size, risk_distance);
    }
}


//+------------------------------------------------------------------+
//| MODULE: Position Sizing & Risk Calculation                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate position size based on risk                            |
//+------------------------------------------------------------------+
double CalculatePositionSize(double risk_distance)
{
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Safety check - halt if drawdown exceeded
    double current_dd = 0;
    if(account_balance > 0) {
        current_dd = (account_balance - account_equity) / account_balance * 100.0;
    }
    
    if(current_dd >= inp_MaxDrawdownPercent) {
        g_trading_allowed = false;
        g_last_rejection_reason = "Max drawdown reached: " + DoubleToString(current_dd, 2) + "%";
        Print("[RISK] TRADING HALTED - ", g_last_rejection_reason);
        return 0;
    }
    
    // Calculate risk amount
    double risk_amount = account_balance * (inp_RiskPerTrade / 100.0);
    
    // Calculate pip value per lot
    double tick_value_per_lot = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_VALUE);
    double tick_size = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_SIZE);
    double point_value = SymbolInfoDouble(g_symbol, SYMBOL_POINT);
    
    double pip_value_per_lot = (tick_value_per_lot / tick_size) * point_value;
    
    // Calculate lot size
    double risk_in_points = risk_distance / point_value;
    double lot_size = risk_amount / (risk_in_points * pip_value_per_lot);
    
    // Normalize to broker lot step
    double lot_step = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_STEP);
    lot_size = MathFloor(lot_size / lot_step) * lot_step;
    
    // Apply broker constraints
    double lot_min = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_MIN);
    double lot_max = SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_MAX);
    
    lot_size = MathMax(lot_min, MathMin(lot_size, lot_max));
    
    // Margin check
    double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    double required_margin = 0;
    
    if(!OrderCalcMargin(ORDER_TYPE_BUY, g_symbol, lot_size, 
                        SymbolInfoDouble(g_symbol, SYMBOL_ASK), required_margin)) {
        Print("[RISK] Failed to calculate margin: ", GetLastError());
        return 0;
    }
    
    double max_margin = free_margin * (inp_MaxMarginUsagePercent / 100.0);
    
    if(required_margin > max_margin) {
        // Reduce lot size to fit margin
        lot_size = lot_size * (max_margin / required_margin);
        lot_size = MathFloor(lot_size / lot_step) * lot_step;
        lot_size = MathMax(lot_min, lot_size);
        
        if(inp_VerboseDebug) {
            Print("[RISK] Lot size reduced due to margin constraints: ", lot_size);
        }
    }
    
    if(inp_VerboseDebug) {
        Print("[RISK] Position size calculated:");
        Print("[RISK] Risk amount: $", DoubleToString(risk_amount, 2));
        Print("[RISK] Risk distance: ", DoubleToString(risk_distance / g_pip_value, 1), " pips");
        Print("[RISK] Lot size: ", DoubleToString(lot_size, 2));
    }
    
    return lot_size;
}

//+------------------------------------------------------------------+
//| Calculate risk amount for a given lot size and distance          |
//+------------------------------------------------------------------+
double CalculateRiskAmount(double lot_size, double risk_distance)
{
    double tick_value_per_lot = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_VALUE);
    double tick_size = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_SIZE);
    double point_value = SymbolInfoDouble(g_symbol, SYMBOL_POINT);
    
    double pip_value_per_lot = (tick_value_per_lot / tick_size) * point_value;
    double risk_in_points = risk_distance / point_value;
    
    return lot_size * risk_in_points * pip_value_per_lot;
}

//+------------------------------------------------------------------+
//| MODULE: Order Placement                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Place market order                                               |
//+------------------------------------------------------------------+
bool PlaceMarketOrder(ENUM_ORDER_TYPE order_type, double lot_size, double sl, double tp, int confluence)
{
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = g_symbol;
    request.volume = lot_size;
    request.type = order_type;
    request.price = (order_type == ORDER_TYPE_BUY) ? 
                    SymbolInfoDouble(g_symbol, SYMBOL_ASK) : 
                    SymbolInfoDouble(g_symbol, SYMBOL_BID);
    request.sl = NormalizePrice(sl);
    request.tp = NormalizePrice(tp);
    request.deviation = (ulong)(inp_MaxSlippagePips * 10);  // Points
    request.magic = MAGIC_NUMBER;
    request.comment = StringFormat("%s_C%d", inp_CommentPrefix, confluence);
    request.type_filling = ORDER_FILLING_FOK;
    
    // Try FOK first
    if(!OrderSend(request, result)) {
        // Try IOC
        request.type_filling = ORDER_FILLING_IOC;
        if(!OrderSend(request, result)) {
            // Try RETURN
            request.type_filling = ORDER_FILLING_RETURN;
            if(!OrderSend(request, result)) {
                Print("[ORDER] Failed to place market order: ", result.retcode, " - ", result.comment);
                g_last_rejection_reason = "Order send failed: " + result.comment;
                return false;
            }
        }
    }
    
    if(result.retcode == TRADE_RETCODE_DONE || result.retcode == TRADE_RETCODE_PLACED) {
        Print("[ORDER] Market order placed successfully!");
        Print("[ORDER] Ticket: ", result.order);
        Print("[ORDER] Type: ", EnumToString(order_type));
        Print("[ORDER] Volume: ", lot_size);
        Print("[ORDER] Price: ", request.price);
        Print("[ORDER] SL: ", sl, " | TP: ", tp);
        return true;
    }
    
    Print("[ORDER] Order failed: ", result.retcode, " - ", result.comment);
    g_last_rejection_reason = "Order retcode: " + IntegerToString(result.retcode);
    return false;
}

//+------------------------------------------------------------------+
//| Place limit order                                                |
//+------------------------------------------------------------------+
bool PlaceLimitOrder(ENUM_ORDER_TYPE order_type, double lot_size, double price, double sl, double tp, int confluence)
{
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_PENDING;
    request.symbol = g_symbol;
    request.volume = lot_size;
    request.type = order_type;
    request.price = NormalizePrice(price);
    request.sl = NormalizePrice(sl);
    request.tp = NormalizePrice(tp);
    request.magic = MAGIC_NUMBER;
    request.comment = StringFormat("%s_C%d", inp_CommentPrefix, confluence);
    request.type_time = ORDER_TIME_SPECIFIED;
    request.expiration = TimeCurrent() + inp_OrderExpiration_Hours * 3600;
    
    if(!OrderSend(request, result)) {
        Print("[ORDER] Failed to place limit order: ", result.retcode, " - ", result.comment);
        g_last_rejection_reason = "Limit order failed: " + result.comment;
        return false;
    }
    
    if(result.retcode == TRADE_RETCODE_DONE || result.retcode == TRADE_RETCODE_PLACED) {
        Print("[ORDER] Limit order placed successfully!");
        Print("[ORDER] Ticket: ", result.order);
        Print("[ORDER] Type: ", EnumToString(order_type));
        Print("[ORDER] Volume: ", lot_size);
        Print("[ORDER] Price: ", price, " | SL: ", sl, " | TP: ", tp);
        Print("[ORDER] Expires: ", TimeToString(request.expiration));
        return true;
    }
    
    Print("[ORDER] Limit order failed: ", result.retcode, " - ", result.comment);
    return false;
}

//+------------------------------------------------------------------+
//| Normalize price to tick size                                     |
//+------------------------------------------------------------------+
double NormalizePrice(double price)
{
    double tick_size = SymbolInfoDouble(g_symbol, SYMBOL_TRADE_TICK_SIZE);
    return NormalizeDouble(MathRound(price / tick_size) * tick_size, g_digits);
}

//+------------------------------------------------------------------+
//| MODULE: Trade Management                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Manage open trades                                               |
//+------------------------------------------------------------------+
void ManageOpenTrades()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;
        
        if(PositionGetString(POSITION_SYMBOL) != g_symbol) continue;
        if(PositionGetInteger(POSITION_MAGIC) != MAGIC_NUMBER) continue;
        
        // Get position details
        double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double current_sl = PositionGetDouble(POSITION_SL);
        double current_tp = PositionGetDouble(POSITION_TP);
        double current_profit = PositionGetDouble(POSITION_PROFIT);
        ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        
        double current_price = (pos_type == POSITION_TYPE_BUY) ? 
                               SymbolInfoDouble(g_symbol, SYMBOL_BID) : 
                               SymbolInfoDouble(g_symbol, SYMBOL_ASK);
        
        double risk_distance = (pos_type == POSITION_TYPE_BUY) ? 
                               (entry_price - current_sl) : 
                               (current_sl - entry_price);
        
        if(risk_distance <= 0) risk_distance = 0.0001;  // Prevent division by zero
        
        double current_R = (pos_type == POSITION_TYPE_BUY) ? 
                           (current_price - entry_price) / risk_distance : 
                           (entry_price - current_price) / risk_distance;
        
        // Partial close at TP1
        double tp1_price = (pos_type == POSITION_TYPE_BUY) ? 
                           entry_price + inp_TP1_RR * risk_distance : 
                           entry_price - inp_TP1_RR * risk_distance;
        
        // Check if we need to do partial close at TP1 (40% position)
        // This is tracked via position comment - skip if already partially closed
        string pos_comment = PositionGetString(POSITION_COMMENT);
        bool partial_done = (StringFind(pos_comment, "TP1_CLOSED") >= 0);
        
        if(current_R >= inp_TP1_RR && !partial_done) {
            // Partial close 40% at TP1
            double partial_volume = NormalizeDouble(PositionGetDouble(POSITION_VOLUME) * 0.4, 2);
            if(partial_volume >= SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_MIN)) {
                PartialClosePosition(ticket, partial_volume, "TP1");
            }
        }
        
        // Breakeven move after TP1 - for BUY, SL should still be below entry before moving
        if(current_R >= inp_TP1_RR && pos_type == POSITION_TYPE_BUY && current_sl < entry_price) {
            double new_sl = entry_price + 5 * g_pip_value;  // Breakeven + 5 pips
            ModifyPosition(ticket, new_sl, current_tp);
            if(inp_VerboseDebug) Print("[MANAGE] Moved SL to breakeven+5 for ticket ", ticket);
        }
        
        // For SELL, SL should still be above entry before moving to BE
        if(current_R >= inp_TP1_RR && pos_type == POSITION_TYPE_SELL && current_sl > entry_price) {
            double new_sl = entry_price - 5 * g_pip_value;  // Breakeven + 5 pips (below entry for sell)
            ModifyPosition(ticket, new_sl, current_tp);
            if(inp_VerboseDebug) Print("[MANAGE] Moved SL to breakeven+5 for ticket ", ticket);
        }
        
        // Partial close at TP2 (another 30%)
        double tp2_R = inp_TP1_RR + (inp_TP_Final_RR - inp_TP1_RR) * 0.5;  // Halfway between TP1 and final
        bool tp2_done = (StringFind(pos_comment, "TP2_CLOSED") >= 0);
        
        if(current_R >= tp2_R && partial_done && !tp2_done) {
            double partial_volume = NormalizeDouble(PositionGetDouble(POSITION_VOLUME) * 0.5, 2); // 30% of remaining 60% = ~0.5 of current
            if(partial_volume >= SymbolInfoDouble(g_symbol, SYMBOL_VOLUME_MIN)) {
                PartialClosePosition(ticket, partial_volume, "TP2");
            }
        }
        
        // Trailing stop
        if(inp_UseTrailingStop && current_R >= inp_TrailActivationR) {
            double trail_distance = inp_TrailDistance_ATR * g_rolling_TR_M15;
            double trail_step = inp_TrailStep_Pips * g_pip_value;
            
            if(pos_type == POSITION_TYPE_BUY) {
                double new_sl = current_price - trail_distance;
                if(new_sl > current_sl + trail_step) {
                    ModifyPosition(ticket, NormalizePrice(new_sl), current_tp);
                    if(inp_VerboseDebug) {
                        Print("[TRAIL] Updated trailing stop for ticket ", ticket, " to ", new_sl);
                    }
                }
            } else {
                double new_sl = current_price + trail_distance;
                if(new_sl < current_sl - trail_step) {
                    ModifyPosition(ticket, NormalizePrice(new_sl), current_tp);
                    if(inp_VerboseDebug) {
                        Print("[TRAIL] Updated trailing stop for ticket ", ticket, " to ", new_sl);
                    }
                }
            }
        }
    }
    
    // Check for expired pending orders
    CheckExpiredOrders();
}

//+------------------------------------------------------------------+
//| Modify position SL/TP                                            |
//+------------------------------------------------------------------+
bool ModifyPosition(ulong ticket, double new_sl, double new_tp)
{
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_SLTP;
    request.position = ticket;
    request.symbol = g_symbol;
    request.sl = NormalizePrice(new_sl);
    request.tp = NormalizePrice(new_tp);
    
    if(!OrderSend(request, result)) {
        Print("[MODIFY] Failed to modify position ", ticket, ": ", GetLastError());
        return false;
    }
    
    return (result.retcode == TRADE_RETCODE_DONE);
}

//+------------------------------------------------------------------+
//| Partial close position                                           |
//+------------------------------------------------------------------+
bool PartialClosePosition(ulong ticket, double volume, string tp_level)
{
    if(!PositionSelectByTicket(ticket)) {
        Print("[PARTIAL] Failed to select position: ", ticket);
        return false;
    }
    
    ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.position = ticket;
    request.symbol = g_symbol;
    request.volume = NormalizeDouble(volume, 2);
    request.type = (pos_type == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
    request.price = (pos_type == POSITION_TYPE_BUY) ? 
                    SymbolInfoDouble(g_symbol, SYMBOL_BID) : 
                    SymbolInfoDouble(g_symbol, SYMBOL_ASK);
    request.deviation = 10;
    request.magic = MAGIC_NUMBER;
    request.comment = tp_level + "_CLOSED";
    
    if(!OrderSend(request, result)) {
        Print("[PARTIAL] Failed to partially close at ", tp_level, ": ", GetLastError());
        return false;
    }
    
    if(result.retcode == TRADE_RETCODE_DONE) {
        Print("[PARTIAL] Closed ", DoubleToString(volume, 2), " lots at ", tp_level, 
              " for ticket ", ticket);
        return true;
    }
    
    Print("[PARTIAL] Order rejected: ", result.retcode);
    return false;
}

//+------------------------------------------------------------------+
//| Check and delete expired pending orders                          |
//+------------------------------------------------------------------+
void CheckExpiredOrders()
{
    for(int i = OrdersTotal() - 1; i >= 0; i--) {
        ulong ticket = OrderGetTicket(i);
        if(ticket <= 0) continue;
        
        if(OrderGetString(ORDER_SYMBOL) != g_symbol) continue;
        if(OrderGetInteger(ORDER_MAGIC) != MAGIC_NUMBER) continue;
        
        datetime expiration = (datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
        
        if(expiration > 0 && TimeCurrent() >= expiration) {
            MqlTradeRequest request = {};
            MqlTradeResult result = {};
            
            request.action = TRADE_ACTION_REMOVE;
            request.order = ticket;
            
            if(OrderSend(request, result)) {
                Print("[ORDER] Expired pending order removed: ", ticket);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Count open positions for this EA                                 |
//+------------------------------------------------------------------+
int CountOpenPositions()
{
    int count = 0;
    
    for(int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if(ticket <= 0) continue;
        
        if(PositionGetString(POSITION_SYMBOL) == g_symbol &&
           PositionGetInteger(POSITION_MAGIC) == MAGIC_NUMBER) {
            count++;
        }
    }
    
    return count;
}
//+------------------------------------------------------------------+
//| MODULE: Risk & Filter Functions                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check daily limits                                               |
//+------------------------------------------------------------------+
bool CheckDailyLimits()
{
    if(g_daily_trades >= inp_MaxTradesPerDay) {
        g_last_rejection_reason = "Max daily trades reached";
        if(inp_VerboseDebug) Print("[FILTER] ", g_last_rejection_reason);
        return false;
    }
    
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double max_daily_risk = account_balance * (inp_MaxDailyRiskPercent / 100.0);
    
    if(g_daily_risk_taken >= max_daily_risk) {
        g_last_rejection_reason = "Max daily risk reached";
        if(inp_VerboseDebug) Print("[FILTER] ", g_last_rejection_reason);
        return false;
    }
    
    if(g_consecutive_losses >= inp_MaxConsecutiveLosses) {
        g_cooldown_until = TimeCurrent() + inp_CooldownPeriod * 60;
        g_last_rejection_reason = "Consecutive losses limit - entering cooldown";
        Print("[FILTER] ", g_last_rejection_reason);
        Print("[FILTER] Cooldown until: ", TimeToString(g_cooldown_until));
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check spread                                                     |
//+------------------------------------------------------------------+
bool CheckSpread()
{
    double ask = SymbolInfoDouble(g_symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(g_symbol, SYMBOL_BID);
    double spread = (ask - bid) / g_pip_value;
    
    if(spread > inp_SpreadMaxPips) {
        g_last_rejection_reason = StringFormat("Spread too wide: %.1f pips", spread);
        if(inp_VerboseDebug) Print("[FILTER] ", g_last_rejection_reason);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check volatility                                                 |
//+------------------------------------------------------------------+
bool CheckVolatility()
{
    if(g_rolling_TR_M15 <= 0 || g_rolling_TR_H4 <= 0) return true;  // Skip if not initialized
    
    double vol_ratio = g_rolling_TR_M15 / g_rolling_TR_H4;
    
    if(vol_ratio < inp_VolFilterMin) {
        g_last_rejection_reason = StringFormat("Volatility too low: %.2f", vol_ratio);
        if(inp_VerboseDebug) Print("[FILTER] ", g_last_rejection_reason);
        return false;
    }
    
    if(vol_ratio > inp_VolFilterMax) {
        g_last_rejection_reason = StringFormat("Volatility too high: %.2f", vol_ratio);
        if(inp_VerboseDebug) Print("[FILTER] ", g_last_rejection_reason);
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check daily reset                                                |
//+------------------------------------------------------------------+
void CheckDailyReset()
{
    MqlDateTime current_time;
    TimeToStruct(TimeGMT(), current_time);
    
    MqlDateTime last_reset_time;
    TimeToStruct(g_last_daily_reset, last_reset_time);
    
    // Reset at 00:00 UTC
    if(current_time.day != last_reset_time.day) {
        if(inp_VerboseDebug) {
            Print("[DAILY] New trading day - resetting counters");
            Print("[DAILY] Previous: Trades=", g_daily_trades, " Risk=$", g_daily_risk_taken);
        }
        
        g_daily_trades = 0;
        g_daily_risk_taken = 0;
        g_daily_profit = 0;
        g_last_daily_reset = TimeGMT();
        
        Print("[DAILY] Daily limits reset for ", TimeToString(TimeGMT(), TIME_DATE));
    }
}

//+------------------------------------------------------------------+
//| MODULE: Time & Session Functions                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if current time is in a killzone                           |
//+------------------------------------------------------------------+
bool IsInKillzone()
{
    if(!inp_EnableLondonKZ && !inp_EnableNewYorkKZ && !inp_AllowOffKillzone) {
        return false;  // No killzones enabled
    }
    
    if(inp_AllowOffKillzone) return true;  // Trade anytime
    
    MqlDateTime time_struct;
    TimeToStruct(TimeGMT(), time_struct);
    
    int current_hour = time_struct.hour;
    int current_min = time_struct.min;
    
    // Check London killzone (07:00-10:00 UTC)
    if(inp_EnableLondonKZ) {
        if((current_hour > LONDON_START_HOUR || 
           (current_hour == LONDON_START_HOUR && current_min >= LONDON_START_MIN)) &&
           (current_hour < LONDON_END_HOUR || 
           (current_hour == LONDON_END_HOUR && current_min < LONDON_END_MIN))) {
            return true;
        }
    }
    
    // Check New York killzone (12:00-16:00 UTC)
    if(inp_EnableNewYorkKZ) {
        if((current_hour > NY_START_HOUR || 
           (current_hour == NY_START_HOUR && current_min >= NY_START_MIN)) &&
           (current_hour < NY_END_HOUR || 
           (current_hour == NY_END_HOUR && current_min < NY_END_MIN))) {
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check if in power hour (first 30min of killzone)                 |
//+------------------------------------------------------------------+
bool IsInPowerHour()
{
    MqlDateTime time_struct;
    TimeToStruct(TimeGMT(), time_struct);
    
    int current_hour = time_struct.hour;
    int current_min = time_struct.min;
    
    // London power hour (07:00-07:30 UTC)
    if(inp_EnableLondonKZ) {
        if(current_hour == LONDON_START_HOUR && current_min < 30) {
            return true;
        }
    }
    
    // New York power hour (12:00-12:30 UTC)
    if(inp_EnableNewYorkKZ) {
        if(current_hour == NY_START_HOUR && current_min < 30) {
            return true;
        }
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Convert UTC to IST for display                                   |
//+------------------------------------------------------------------+
string ConvertUTCtoIST(datetime utc_time)
{
    datetime ist_time = utc_time + IST_OFFSET_SECONDS;
    return TimeToString(ist_time, TIME_DATE|TIME_SECONDS);
}

//+------------------------------------------------------------------+
//| MODULE: Display & Logging Functions                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Display chart information                                        |
//+------------------------------------------------------------------+
void DisplayChartInfo()
{
    double win_rate = (g_total_trades > 0) ? (g_winning_trades * 100.0 / g_total_trades) : 0;
    double profit_factor = (g_gross_loss > 0) ? (g_gross_profit / g_gross_loss) : 0;
    double avg_win = (g_winning_trades > 0) ? (g_gross_profit / g_winning_trades) : 0;
    double avg_loss = (g_total_trades - g_winning_trades > 0) ? 
                      (g_gross_loss / (g_total_trades - g_winning_trades)) : 0;
    double expectancy = (win_rate/100 * avg_win) - ((1 - win_rate/100) * avg_loss);
    
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double current_dd = (account_balance > 0) ? 
                        ((account_balance - account_equity) / account_balance * 100) : 0;
    
    double current_spread = (SymbolInfoDouble(g_symbol, SYMBOL_ASK) - 
                             SymbolInfoDouble(g_symbol, SYMBOL_BID)) / g_pip_value;
    
    string bias_str = (g_HTF_bias == BIAS_BULLISH) ? "BULLISH" : 
                      (g_HTF_bias == BIAS_BEARISH) ? "BEARISH" : "NEUTRAL";
    
    string killzone_status = IsInKillzone() ? "YES" : "NO";
    if(IsInKillzone() && IsInPowerHour()) {
        killzone_status += " (POWER HOUR)";
    }
    
    Comment(StringFormat(
        "═══════════════════════════════════════════════════\n" +
        "       OPTIMUS PRIME ICT EA v%s | %s M15\n" +
        "═══════════════════════════════════════════════════\n" +
        "PERFORMANCE METRICS:\n" +
        "  Total Trades: %d | Win Rate: %.1f%%\n" +
        "  Profit Factor: %.2f | Expectancy: $%.2f\n" +
        "  Gross P/L: $%.2f | Net P/L: $%.2f\n" +
        "  Current DD: %.2f%% | Max DD: %.2f%%\n" +
        "  Consecutive W/L: %d/%d\n" +
        "───────────────────────────────────────────────────\n" +
        "DAILY STATUS:\n" +
        "  Trades Today: %d/%d\n" +
        "  Risk Taken: $%.2f / $%.2f\n" +
        "  Daily P/L: $%.2f\n" +
        "───────────────────────────────────────────────────\n" +
        "MARKET CONDITIONS:\n" +
        "  HTF Bias: %s\n" +
        "  In Killzone: %s\n" +
        "  Trading Allowed: %s\n" +
        "  Spread: %.1f pips\n" +
        "  Rolling TR (M15): %.5f\n" +
        "───────────────────────────────────────────────────\n" +
        "ACTIVE SETUPS:\n" +
        "  Bullish FVG: %s | OB: %s | Sweep: %s\n" +
        "  Bearish FVG: %s | OB: %s | Sweep: %s\n" +
        "───────────────────────────────────────────────────\n" +
        "Last Rejection: %s\n" +
        "═══════════════════════════════════════════════════",
        EA_VERSION, g_symbol,
        g_total_trades, win_rate,
        profit_factor, expectancy,
        g_gross_profit - g_gross_loss, g_net_profit,
        current_dd, g_max_drawdown,
        g_consecutive_wins, g_consecutive_losses,
        g_daily_trades, inp_MaxTradesPerDay,
        g_daily_risk_taken, account_balance * (inp_MaxDailyRiskPercent / 100.0),
        g_daily_profit,
        bias_str,
        killzone_status,
        g_trading_allowed ? "YES" : "NO",
        current_spread,
        g_rolling_TR_M15,
        g_fvg_bullish.valid ? "YES" : "NO",
        g_ob_bullish.valid ? "YES" : "NO",
        g_liq_sweep_bullish.detected ? "YES" : "NO",
        g_fvg_bearish.valid ? "YES" : "NO",
        g_ob_bearish.valid ? "YES" : "NO",
        g_liq_sweep_bearish.detected ? "YES" : "NO",
        g_last_rejection_reason != "" ? g_last_rejection_reason : "None"
    ));
}

//+------------------------------------------------------------------+
//| Get uninit reason as text                                        |
//+------------------------------------------------------------------+
string GetUninitReasonText(int reason)
{
    switch(reason) {
        case REASON_PROGRAM: return "EA stopped by user";
        case REASON_REMOVE: return "EA removed from chart";
        case REASON_RECOMPILE: return "EA recompiled";
        case REASON_CHARTCHANGE: return "Chart symbol/period changed";
        case REASON_CHARTCLOSE: return "Chart closed";
        case REASON_PARAMETERS: return "Input parameters changed";
        case REASON_ACCOUNT: return "Account changed";
        case REASON_TEMPLATE: return "Template changed";
        case REASON_INITFAILED: return "Initialization failed";
        case REASON_CLOSE: return "Terminal closing";
        default: return "Unknown reason";
    }
}

//+------------------------------------------------------------------+
//| OnTradeTransaction - Track trade results                         |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
    // Only process deal additions (completed trades)
    if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
    
    // Get deal details
    ulong deal_ticket = trans.deal;
    if(deal_ticket == 0) return;
    
    // Select the deal
    if(!HistoryDealSelect(deal_ticket)) return;
    
    // Check if it's our EA's trade
    if(HistoryDealGetInteger(deal_ticket, DEAL_MAGIC) != MAGIC_NUMBER) return;
    if(HistoryDealGetString(deal_ticket, DEAL_SYMBOL) != g_symbol) return;
    
    ENUM_DEAL_ENTRY deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);
    
    // Only process exits (not entries)
    if(deal_entry != DEAL_ENTRY_OUT && deal_entry != DEAL_ENTRY_OUT_BY) return;
    
    double deal_profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
    double deal_swap = HistoryDealGetDouble(deal_ticket, DEAL_SWAP);
    double deal_commission = HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
    double net_profit = deal_profit + deal_swap + deal_commission;
    
    // Update performance metrics
    g_total_trades++;
    g_daily_profit += net_profit;
    g_net_profit += net_profit;
    
    if(net_profit > 0) {
        g_winning_trades++;
        g_gross_profit += net_profit;
        g_consecutive_wins++;
        g_consecutive_losses = 0;
        
        if(g_consecutive_wins > g_max_consecutive_wins) {
            g_max_consecutive_wins = g_consecutive_wins;
        }
        
        Print("[TRADE] WIN: $", DoubleToString(net_profit, 2), 
              " | Total Wins: ", g_winning_trades, "/", g_total_trades,
              " | Consecutive Wins: ", g_consecutive_wins);
    } else {
        g_gross_loss += MathAbs(net_profit);
        g_consecutive_losses++;
        g_consecutive_wins = 0;
        
        if(g_consecutive_losses > g_max_consecutive_losses) {
            g_max_consecutive_losses = g_consecutive_losses;
        }
        
        Print("[TRADE] LOSS: $", DoubleToString(net_profit, 2),
              " | Consecutive Losses: ", g_consecutive_losses, "/", inp_MaxConsecutiveLosses);
    }
    
    // Update drawdown
    double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double current_dd = (account_balance > 0) ? 
                        ((g_peak_balance - account_equity) / g_peak_balance * 100) : 0;
    
    if(current_dd > g_max_drawdown) {
        g_max_drawdown = current_dd;
    }
    
    if(account_balance > g_peak_balance) {
        g_peak_balance = account_balance;
    }
    
    // Log to CSV
    LogTradeToCSV(deal_ticket, net_profit);
    
    // Calculate win rate for logging
    double win_rate = (g_total_trades > 0) ? (g_winning_trades * 100.0 / g_total_trades) : 0;
    double profit_factor = (g_gross_loss > 0) ? (g_gross_profit / g_gross_loss) : 0;
    
    Print("[STATS] Win Rate: ", DoubleToString(win_rate, 1), "%",
          " | PF: ", DoubleToString(profit_factor, 2),
          " | Max DD: ", DoubleToString(g_max_drawdown, 2), "%");
}

//+------------------------------------------------------------------+
//| Log trade to CSV file                                            |
//+------------------------------------------------------------------+
void LogTradeToCSV(ulong deal_ticket, double net_profit)
{
    if(!inp_EnableCSVLog) return;
    
    // Build CSV file path
    string filename = "OptimusPrime_" + g_symbol + "_TradeLog.csv";
    
    int file_handle = FileOpen(filename, FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON|FILE_SHARE_READ, ",");
    if(file_handle == INVALID_HANDLE) {
        Print("[CSV] Failed to open log file: ", GetLastError());
        return;
    }
    
    // Move to end of file
    FileSeek(file_handle, 0, SEEK_END);
    
    // Get deal details from history
    if(!HistoryDealSelect(deal_ticket)) {
        FileClose(file_handle);
        return;
    }
    
    datetime deal_time = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
    double deal_price = HistoryDealGetDouble(deal_ticket, DEAL_PRICE);
    double deal_volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
    ENUM_DEAL_TYPE deal_type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
    long position_id = HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);
    
    // Find entry deal for this position
    datetime entry_time = 0;
    double entry_price = 0;
    double entry_sl = 0;
    double entry_tp = 0;
    
    if(HistorySelectByPosition(position_id)) {
        for(int i = 0; i < HistoryDealsTotal(); i++) {
            ulong entry_ticket = HistoryDealGetTicket(i);
            ENUM_DEAL_ENTRY entry_type = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(entry_ticket, DEAL_ENTRY);
            if(entry_type == DEAL_ENTRY_IN) {
                entry_time = (datetime)HistoryDealGetInteger(entry_ticket, DEAL_TIME);
                entry_price = HistoryDealGetDouble(entry_ticket, DEAL_PRICE);
                break;
            }
        }
    }
    
    // Calculate R-multiple
    double risk_distance = MathAbs(entry_price - entry_sl);
    double r_multiple = (risk_distance > 0) ? (net_profit / (risk_distance * deal_volume * g_pip_value * 10)) : 0;
    
    // Determine trade direction
    string direction = (deal_type == DEAL_TYPE_BUY) ? "SELL" : "BUY";  // Exit type is opposite of position
    
    // Win rate calculation
    double win_rate = (g_total_trades > 0) ? (g_winning_trades * 100.0 / g_total_trades) : 0;
    double profit_factor = (g_gross_loss > 0) ? (g_gross_profit / g_gross_loss) : 0;
    
    // Build CSV line (42 fields)
    string csv_line = StringFormat(
        "%s,%s,%s,%d,%s,%.5f,%.5f,%.5f,%.5f,%.2f," +      // 1-10
        "%.5f,%.2f,%.2f,%.2f,%.2f,%s,%s,%s,%s,%s," +      // 11-20
        "%s,%s,%.2f,%.2f,%d,%d,%d,%d,%d,%.2f," +          // 21-30
        "%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.5f,%.5f,%s,%s," + // 31-40
        "%.2f,%.2f",                                        // 41-42
        TimeToString(deal_time, TIME_DATE),                 // 1: Date
        TimeToString(deal_time, TIME_MINUTES),              // 2: Time (UTC)
        ConvertUTCtoIST(deal_time),                         // 3: Time (IST)
        deal_ticket,                                         // 4: Ticket
        direction,                                           // 5: Direction
        entry_price,                                         // 6: Entry Price
        deal_price,                                          // 7: Exit Price
        entry_sl,                                            // 8: Stop Loss
        entry_tp,                                            // 9: Take Profit
        deal_volume,                                         // 10: Lots
        net_profit > 0 ? deal_price : entry_price,          // 11: Actual Exit
        net_profit,                                          // 12: P/L $
        r_multiple,                                          // 13: R-Multiple
        g_daily_profit,                                      // 14: Daily P/L
        g_net_profit,                                        // 15: Cumulative P/L
        g_HTF_bias == BIAS_BULLISH ? "BULLISH" : 
          (g_HTF_bias == BIAS_BEARISH ? "BEARISH" : "NEUTRAL"), // 16: HTF Bias
        g_fvg_bullish.valid ? "YES" : "NO",                 // 17: FVG Valid
        g_ob_bullish.valid ? "YES" : "NO",                  // 18: OB Valid
        g_liq_sweep_bullish.detected ? "YES" : "NO",        // 19: Sweep Valid
        IsInKillzone() ? "YES" : "NO",                      // 20: In Killzone
        IsInPowerHour() ? "YES" : "NO",                     // 21: Power Hour
        net_profit > 0 ? "WIN" : "LOSS",                    // 22: Result
        win_rate,                                            // 23: Win Rate
        profit_factor,                                       // 24: Profit Factor
        g_winning_trades,                                    // 25: Total Wins
        g_total_trades - g_winning_trades,                  // 26: Total Losses
        g_consecutive_wins,                                  // 27: Consecutive Wins
        g_consecutive_losses,                                // 28: Consecutive Losses
        g_daily_trades,                                      // 29: Trades Today
        g_daily_risk_taken,                                  // 30: Risk Today
        g_rolling_TR_M15,                                    // 31: Rolling TR M15
        g_rolling_TR_H1,                                     // 32: Rolling TR H1
        g_rolling_TR_H4,                                     // 33: Rolling TR H4
        g_max_drawdown,                                      // 34: Max DD %
        AccountInfoDouble(ACCOUNT_BALANCE),                  // 35: Account Balance
        AccountInfoDouble(ACCOUNT_EQUITY),                   // 36: Account Equity
        g_last_swing_high,                                   // 37: Last Swing High
        g_last_swing_low,                                    // 38: Last Swing Low
        "",                                                  // 39: Setup Comment (placeholder)
        g_last_rejection_reason,                             // 40: Last Rejection
        0.0,                                                 // 41: Confluence Score
        (double)((deal_time - entry_time) / 60)             // 42: Trade Duration (min)
    );
    
    FileWrite(file_handle, csv_line);
    FileClose(file_handle);
    
    if(inp_VerboseDebug) Print("[CSV] Trade logged: Ticket ", deal_ticket);
}

//+------------------------------------------------------------------+
//| Initialize CSV header                                            |
//+------------------------------------------------------------------+
void WriteCSVHeader()
{
    if(!inp_EnableCSVLog) return;
    
    string filename = "OptimusPrime_" + g_symbol + "_TradeLog.csv";
    
    // Check if file exists
    if(FileIsExist(filename, FILE_COMMON)) return;
    
    int file_handle = FileOpen(filename, FILE_WRITE|FILE_CSV|FILE_COMMON, ",");
    if(file_handle == INVALID_HANDLE) {
        Print("[CSV] Failed to create log file: ", GetLastError());
        return;
    }
    
    // Write header row
    string header = "Date,Time_UTC,Time_IST,Ticket,Direction,Entry,Exit,SL,TP,Lots," +
                    "ActualExit,PL_USD,R_Multiple,DailyPL,CumulativePL,HTF_Bias,FVG,OB,Sweep,InKillzone," +
                    "PowerHour,Result,WinRate,ProfitFactor,TotalWins,TotalLosses,ConsecWins,ConsecLosses,TradesToday,RiskToday," +
                    "TR_M15,TR_H1,TR_H4,MaxDD,Balance,Equity,SwingHigh,SwingLow,SetupComment,LastRejection," +
                    "ConfluenceScore,TradeDuration_Min";
    
    FileWrite(file_handle, header);
    FileClose(file_handle);
    
    Print("[CSV] Trade log initialized: ", filename);
}

//+------------------------------------------------------------------+
//| End of OptimusPrime.mq5                                          |
//+------------------------------------------------------------------+
