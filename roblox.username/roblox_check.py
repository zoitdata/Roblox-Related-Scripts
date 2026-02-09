import requests
import time

INPUT_FILE = "names.txt"      # can be changed depending on your text file
OUTPUT_FILE = "freenames.txt" # can be changed depending on your text file     
BATCH_SIZE = 10               # number of usernames to check per single request
SLEEP_TIME = 1.2              # sleep timer to not reach request limits

URL = "https://users.roblox.com/v1/usernames/users"
HEADERS = {
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0"
}

def check_usernames(usernames):
    """Checks list of usernames via Roblox API and returns their availability."""
    payload = {
        "usernames": usernames,
        "excludeBannedUsers": False
    }

    try:
        response = requests.post(URL, json=payload, headers=HEADERS, timeout=10)
        response.raise_for_status()
        return response.json().get("data", [])
    except Exception as e:
        print(f"Error with API request: {e}")
        return [{"requestedUsername": name, "isAvailable": False, "reason": "API-Error"} for name in usernames]

def main():
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        names = [line.strip() for line in f if line.strip()]

    free_names = []

    print(f"Checking {len(names)} Usernames...\n")
    for i in range(0, len(names), BATCH_SIZE):
        batch = names[i:i + BATCH_SIZE]
        results = check_usernames(batch)

        for result in results:
            name = result.get("requestedUsername", "")
            available = result.get("isAvailable", False)  
            reason = result.get("reason", "")

            if available:
                print(f"✔ Available: {name}")
                free_names.append(name)
                with open(OUTPUT_FILE, "a", encoding="utf-8") as out:
                    out.write(name + "\n")
            else:
                if reason:
                    print(f"✖ available / unavailable: {name} ({reason})")
                else:
                    print(f"✖ unavailable: {name}")

        time.sleep(SLEEP_TIME)  

    print("\n===== DONE =====")
    print(f"available usernames: {len(free_names)}")
    for name in free_names:
        print(f"- {name}")

    print(f"\nResults saved to: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()