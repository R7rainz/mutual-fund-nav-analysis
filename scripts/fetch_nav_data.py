import pandas as pd
import requests

SCHEMES = {
    "UTI Nifty 50 Index Fund - Direct Growth": "120716",
    "HDFC Index Fund Nifty 50 Plan - Direct Growth": "119063",
    "ICICI Prudential Nifty 50 Index Fund - Direct Growth": "120503",
    "SBI Nifty Index Fund - Direct Growth": "119800",
}


def fetch_scheme_nav(scheme_name: str, scheme_code: str) -> pd.DataFrame:
    url = f"https://api.mfapi.in/mf/{scheme_code}"
    response = requests.get(url, timeout=30)
    response.raise_for_status()

    payload = response.json()

    rows = payload["data"]
    df = pd.DataFrame(rows)

    df["scheme_code"] = scheme_code
    df["scheme_name"] = scheme_name
    df["nav"] = pd.to_numeric(df["nav"], errors="coerce")
    df["date"] = pd.to_datetime(df["date"], format="%d-%m-%Y", errors="coerce")

    df = df.dropna(subset=["date", "nav"])
    df = df.sort_values("date")

    return df[["scheme_code", "scheme_name", "date", "nav"]]


def main():
    all_data = []

    for scheme_name, scheme_code in SCHEMES.items():
        print(f"Fetching: {scheme_name}")
        df = fetch_scheme_nav(scheme_name, scheme_code)
        all_data.append(df)

    nav_data = pd.concat(all_data, ignore_index=True)

    nav_data.to_csv("data/raw/nav_data.csv", index=False)

    print("Saved data/raw/nav_data.csv")
    print(nav_data.head())
    print(nav_data.tail())
    print("Rows:", len(nav_data))


if __name__ == "__main__":
    main()
