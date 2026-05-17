# Mutual Fund Performance Analysis - Insights

## Overview

This report summarizes the key findings from the mutual fund NAV analysis project.

The analysis compares selected Nifty 50 index mutual funds using historical NAV data fetched from MFAPI. The objective is to understand fund performance using return, volatility, maximum drawdown, NAV movement, and SIP simulation.

This insights report focuses on both performance and risk so that the fund comparison is not based only on returns.

---

## Purpose of the Analysis

The purpose of this analysis is to answer practical investment-related questions such as:

- Which mutual fund generated the highest return?
- Which fund showed the highest volatility?
- Which fund had the largest maximum drawdown?
- Which fund appeared more stable during the selected period?
- How did NAV values move over time?
- How would a monthly SIP investment have performed?

---

## Key Findings

### 1. NAV Trend Analysis

The selected mutual funds showed broadly similar NAV movement because all of them belong to the Nifty 50 index fund category.

Since these funds track the same benchmark, their NAV trends are expected to move in a similar direction over time.

However, small differences can still appear due to factors such as:

- Expense ratio
- Tracking error
- Fund management efficiency
- Cash holding differences
- NAV calculation differences

This means that even funds tracking the same index may not produce exactly identical results.

---

### 2. Return Comparison

Total return was calculated using the first available NAV value and the last available NAV value for each fund.

The return percentage helps measure how much each fund grew during the selected time period.

Since all selected schemes are index funds, the difference in returns is expected to be relatively small. A fund with a slightly higher return performed better during the selected period, but return alone should not be treated as the final decision-making factor.

A better fund comparison should also include risk-related metrics such as volatility and maximum drawdown.

---

### 3. Volatility Comparison

Annualized volatility was calculated using daily percentage returns.

Volatility helps measure how much the NAV fluctuated over time.

A fund with higher volatility had larger NAV movements, while a fund with lower volatility appeared more stable.

For investors, volatility is important because it shows how smooth or unstable the investment journey was. Even if two funds generate similar returns, the fund with lower volatility may be preferred by investors who want more stability.

---

### 4. Maximum Drawdown Analysis

Maximum drawdown was calculated to identify the largest fall from a previous peak NAV.

This metric is useful because investors do not only care about how much a fund grows. They also care about how much the fund can fall during market corrections.

A larger maximum drawdown means the fund experienced a deeper decline from its previous high. A smaller drawdown may indicate relatively better downside protection.

Maximum drawdown is especially useful for understanding risk during weak market phases.

---

### 5. SIP Simulation

A monthly SIP investment of Rs. 5,000 was simulated for each fund.

The SIP simulation helps understand how regular monthly investing would have performed across different funds during the selected period.

This is useful because many retail investors invest in mutual funds through SIPs instead of investing a large amount at once.

SIP analysis gives a more practical view of investment performance because it reflects real-world investing behavior.

---

### 6. Stability of Funds

Because all selected funds track the Nifty 50 index, their returns and NAV movements were mostly similar.

However, small differences in volatility and maximum drawdown can help identify which fund was relatively more stable.

A stable fund is not necessarily the one with the highest return. A stable fund is one that gives reasonable returns while keeping volatility and downside risk under control.

---

## Business Insights

### 1. Return Alone Is Not Enough

A fund may show good returns, but it may also have higher volatility or a larger drawdown.

Therefore, fund comparison should not be based only on total return.

A better comparison should include:

- Return
- Volatility
- Maximum drawdown
- SIP outcome
- NAV movement

This gives a more complete picture of fund performance.

---

### 2. Risk Metrics Improve Decision-Making

Volatility and maximum drawdown help investors understand the risk involved in a fund.

While return shows how much the fund has grown, risk metrics show how difficult or unstable the investment journey was.

This is important because two funds may have similar returns but different risk levels.

---

### 3. SIP Simulation Is Useful for Retail Investors

SIP simulation is more practical for retail investors because many investors invest monthly instead of investing a lump sum amount.

By simulating monthly SIP investments, the analysis shows how regular investing would have performed over time.

This makes the project more relevant for fintech platforms, mutual fund dashboards, and investment recommendation systems.

---

### 4. Index Funds Require Detailed Comparison

Index funds usually generate similar returns because they track the same benchmark.

Therefore, investors should compare more than just returns.

Important comparison factors include:

- Expense ratio
- Tracking error
- Volatility
- Drawdown
- Fund size
- Consistency of performance

This helps investors select funds more carefully.

---

### 5. Dashboard-Based Fund Comparison Can Help Users

Fintech platforms can use this type of analysis to build better mutual fund comparison dashboards.

Instead of showing only NAV charts or past returns, dashboards should include multiple performance and risk metrics together.

A good dashboard should show:

- NAV trend
- Total return
- Annualized volatility
- Maximum drawdown
- SIP result
- Final SIP value

This can help users make more informed investment decisions.

---

## Business Recommendations

1. Fund comparison should not be based only on returns. Risk metrics such as volatility and maximum drawdown should also be considered.

2. Index funds with similar returns can still differ slightly in risk, drawdown, and NAV behavior.

3. SIP simulation should be included in mutual fund analysis because it reflects a realistic investment pattern.

4. Fintech platforms should present return, risk, and SIP results together to make fund comparison easier for users.

5. Investors should use historical performance as a reference, not as a guarantee of future returns.

6. Mutual fund dashboards should make risk metrics easy to understand for retail investors.

7. Funds should be compared within the same category for a fair comparison.

---

## Final Insights Summary

The analysis shows that selected Nifty 50 index mutual funds moved in a similar direction because they track the same benchmark.

Return differences between the funds were relatively small, which is expected for index funds. However, risk metrics such as volatility and maximum drawdown helped identify differences in fund behavior.

The SIP simulation added practical value by showing how regular monthly investing would have performed over time.

Overall, the analysis proves that mutual fund comparison should include both performance and risk metrics. A complete fund comparison should not only answer which fund gave the highest return, but also which fund was more stable and suitable for regular investors.

---

## Conclusion

This project demonstrates how real mutual fund NAV data can be used to generate meaningful investment insights.

Using Python, SQL, and data visualization, the analysis converts raw NAV data into useful performance and risk metrics.

The key conclusion is that fund comparison should not be limited to returns. Volatility, maximum drawdown, SIP performance, and NAV movement are equally important for understanding mutual fund behavior.

This type of analysis can be useful for fintech platforms, investment dashboards, and retail investors who want to compare mutual funds in a more data-driven way.
