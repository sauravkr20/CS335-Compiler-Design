def compute_min() -> float:
  min_value = None
  for i in range(len(data)):
    if not min_value:
      min_value = data[i]
    elif data[i] < min_value:
      min_value = data[i]
  return min_value


def compute_avg() -> float:
  avg_value = None
  sum = 0
  for i in range(len(data)):
    sum += data[i]
  return sum / len(data)


def main():
  min_value: float = compute_min()
  print("Minimum value: ")
  print(min_value)
  avg_value: float = compute_avg()
  print("Average value: ")
  print(avg_value)


if __name__ == "__main__":
  main()
