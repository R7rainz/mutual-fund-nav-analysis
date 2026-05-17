import os

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


RAW_DATA_PATH = "data/raw/nav_data.csv"
CLEANED_DATA_PATH = "data/cleaned/cleaned_nav_data.csv"

IMAGES_DIR = "images"
REPORTS_DIR = "reports"


def create_directories():
    os.makedirs("data/cleaned", exist_ok=True)
    os.makedirs(IMAGES_DIR, exist_ok=True)
    os.makedirs(REPORTS_DIR, exist_ok=True)


def load_and_clean_data():
    df = pd.read_csv(RAW_DATA_PATH)

    df["date"] = pd.to_datetime(df["date"])
    df["nav"] = pd.to_numeric(df["nav"], errors="coerce")

    df = df.dropna(subset=["date", "nav"])
    df = df.drop_duplicates()
    df = df.sort_values(["scheme_name", "date"])

    df.to_csv(CLEANED_DATA_PATH, index=False)

    return df


def print_dataset_summary(df):
    print("\n========== DATASET SUMMARY ==========")
    print("Rows:", len(df))
    print("Columns:", len(df.columns))
    print("\nColumns:")
    print(df.columns.tolist())

    print("\nSchemes:")
    print(df["scheme_name"].value_counts())

    print("\nDate range:")
    print(df["date"].min(), "to", df["date"].max())

    print("\nMissing values:")
    print(df.isnull().sum())


def plot_nav_trend(df):
    plt.figure(figsize=(12, 6))

    for scheme in df["scheme_name"].unique():
        scheme_data = df[df["scheme_name"] == scheme]
        plt.plot(scheme_data["date"], scheme_data["nav"], label=scheme)

    plt.title("NAV Trend of Nifty 50 Index Funds")
    plt.xlabel("Date")
    plt.ylabel("NAV")
    plt.legend()
    plt.tight_layout()
    plt.savefig(f"{IMAGES_DIR}/nav_trend.png")
    plt.close()


def calculate_returns(df):
    returns_summary = []

    for scheme in df["scheme_name"].unique():
        scheme_data = df[df["scheme_name"] == scheme].sort_values("date")

        start_nav = scheme_data.iloc[0]["nav"]
        end_nav = scheme_data.iloc[-1]["nav"]

        total_return = ((end_nav - start_nav) / start_nav) * 100

        returns_summary.append(
            {
                "scheme_name": scheme,
                "start_date": scheme_data.iloc[0]["date"],
                "end_date": scheme_data.iloc[-1]["date"],
                "start_nav": start_nav,
                "end_nav": end_nav,
                "total_return_percent": total_return,
            }
        )

    returns_df = pd.DataFrame(returns_summary)
    returns_df = returns_df.sort_values("total_return_percent", ascending=False)

    returns_df.to_csv(f"{REPORTS_DIR}/returns_summary.csv", index=False)

    returns_df.plot(
        x="scheme_name",
        y="total_return_percent",
        kind="bar",
        figsize=(10, 5),
        legend=False,
    )

    plt.title("Total Return Comparison")
    plt.xlabel("Scheme")
    plt.ylabel("Total Return (%)")
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig(f"{IMAGES_DIR}/returns_comparison.png")
    plt.close()

    return returns_df


def calculate_volatility(df):
    df = df.copy()
    df["daily_return"] = df.groupby("scheme_name")["nav"].pct_change()

    volatility_df = df.groupby("scheme_name")["daily_return"].std().reset_index()

    volatility_df["annualized_volatility_percent"] = (
        volatility_df["daily_return"] * np.sqrt(252) * 100
    )

    volatility_df = volatility_df.sort_values(
        "annualized_volatility_percent",
        ascending=False,
    )

    volatility_df.to_csv(f"{REPORTS_DIR}/volatility_summary.csv", index=False)

    volatility_df.plot(
        x="scheme_name",
        y="annualized_volatility_percent",
        kind="bar",
        figsize=(10, 5),
        legend=False,
    )

    plt.title("Annualized Volatility Comparison")
    plt.xlabel("Scheme")
    plt.ylabel("Volatility (%)")
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig(f"{IMAGES_DIR}/volatility_comparison.png")
    plt.close()

    return volatility_df


def calculate_drawdown(df):
    drawdown_summary = []

    for scheme in df["scheme_name"].unique():
        scheme_data = df[df["scheme_name"] == scheme].copy()
        scheme_data = scheme_data.sort_values("date")

        scheme_data["running_max_nav"] = scheme_data["nav"].cummax()
        scheme_data["drawdown"] = (
            scheme_data["nav"] - scheme_data["running_max_nav"]
        ) / scheme_data["running_max_nav"]

        max_drawdown = scheme_data["drawdown"].min() * 100

        drawdown_summary.append(
            {
                "scheme_name": scheme,
                "max_drawdown_percent": max_drawdown,
            }
        )

    drawdown_df = pd.DataFrame(drawdown_summary)
    drawdown_df = drawdown_df.sort_values("max_drawdown_percent")

    drawdown_df.to_csv(f"{REPORTS_DIR}/drawdown_summary.csv", index=False)

    return drawdown_df


def simulate_sip(df):
    monthly_sip_amount = 5000
    sip_results = []

    for scheme in df["scheme_name"].unique():
        scheme_data = df[df["scheme_name"] == scheme].copy()
        scheme_data = scheme_data.sort_values("date")
        scheme_data["month"] = scheme_data["date"].dt.to_period("M")

        monthly_nav = scheme_data.groupby("month").first().reset_index()

        monthly_nav["units_bought"] = monthly_sip_amount / monthly_nav["nav"]
        total_units = monthly_nav["units_bought"].sum()

        total_invested = monthly_sip_amount * len(monthly_nav)
        latest_nav = monthly_nav.iloc[-1]["nav"]
        current_value = total_units * latest_nav

        sip_return_percent = ((current_value - total_invested) / total_invested) * 100

        sip_results.append(
            {
                "scheme_name": scheme,
                "months_invested": len(monthly_nav),
                "total_invested": total_invested,
                "current_value": current_value,
                "sip_return_percent": sip_return_percent,
            }
        )

    sip_df = pd.DataFrame(sip_results)
    sip_df = sip_df.sort_values("sip_return_percent", ascending=False)

    sip_df.to_csv(f"{REPORTS_DIR}/sip_summary.csv", index=False)

    sip_df.plot(
        x="scheme_name",
        y="sip_return_percent",
        kind="bar",
        figsize=(10, 5),
        legend=False,
    )

    plt.title("SIP Return Comparison")
    plt.xlabel("Scheme")
    plt.ylabel("SIP Return (%)")
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig(f"{IMAGES_DIR}/sip_simulation.png")
    plt.close()

    return sip_df


def main():
    create_directories()

    df = load_and_clean_data()
    print_dataset_summary(df)

    plot_nav_trend(df)

    returns_df = calculate_returns(df)
    volatility_df = calculate_volatility(df)
    drawdown_df = calculate_drawdown(df)
    sip_df = simulate_sip(df)

    print("\n========== RETURNS SUMMARY ==========")
    print(returns_df)

    print("\n========== VOLATILITY SUMMARY ==========")
    print(volatility_df)

    print("\n========== DRAWDOWN SUMMARY ==========")
    print(drawdown_df)

    print("\n========== SIP SUMMARY ==========")
    print(sip_df)

    print("\nAnalysis completed successfully.")
    print("Charts saved in images/")
    print("Reports saved in reports/")


if __name__ == "__main__":
    main()
