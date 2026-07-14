# Micro items: Date/Time/DateTime/NaiveDateTime/Calendar/Duration + Access.
# All expectations verified against Elixir 1.19.5 / OTP 28.

[
  # ── datetime ────────────────────────────────────────────────────────────
  %{
    id: "datetime/date-add-days",
    prompt: ~S{`input` is a `Date`. Return the date exactly one day later, as a `Date`.},
    solution: ~S{Date.add(input, 1)},
    checks: [
      {~S{~D[2024-02-28]}, ~S{~D[2024-02-29]}},
      {~S{~D[2024-12-31]}, ~S{~D[2025-01-01]}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/date-diff",
    prompt:
      ~S|`input` is a tuple `{later, earlier}` of two `Date` structs. Return the number of days from `earlier` to `later` as an integer (positive when `later` is chronologically after `earlier`, negative when before).|,
    solution: ~S{Date.diff(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{~D[2024-03-01], ~D[2024-02-28]}|, ~S{2}},
      {~S|{~D[2024-01-01], ~D[2024-01-01]}|, ~S{0}},
      {~S|{~D[2023-12-31], ~D[2024-01-02]}|, ~S{-2}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/date-compare",
    prompt:
      ~S|`input` is a tuple `{a, b}` of two `Date` structs. Return the atom `:lt`, `:eq`, or `:gt` describing how `a` relates to `b` in chronological order.|,
    solution: ~S{Date.compare(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{~D[2024-01-31], ~D[2024-02-01]}|, ~S{:lt}},
      {~S|{~D[2024-02-01], ~D[2024-01-31]}|, ~S{:gt}},
      {~S|{~D[2024-06-15], ~D[2024-06-15]}|, ~S{:eq}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/date-before",
    prompt:
      ~S|`input` is a tuple `{a, b}` of two `Date` structs. Return a boolean: `true` exactly when `a` is chronologically strictly before `b`.|,
    solution: ~S{Date.before?(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{~D[2024-01-31], ~D[2024-02-01]}|, ~S{true}},
      {~S|{~D[2024-02-01], ~D[2024-02-01]}|, ~S{false}}
    ],
    tags: [:date, :drift],
    difficulty: :easy
  },
  %{
    id: "datetime/date-after",
    prompt:
      ~S|`input` is a tuple `{a, b}` of two `Date` structs. Return a boolean: `true` exactly when `a` is chronologically strictly after `b`.|,
    solution: ~S{Date.after?(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{~D[2024-02-01], ~D[2024-01-31]}|, ~S{true}},
      {~S|{~D[2024-02-01], ~D[2024-02-01]}|, ~S{false}},
      {~S|{~D[2023-05-05], ~D[2024-05-05]}|, ~S{false}}
    ],
    tags: [:date, :drift],
    difficulty: :easy
  },
  %{
    id: "datetime/day-of-week",
    prompt:
      ~S{`input` is a `Date`. Return its day of the week as an integer, where Monday is 1 and Sunday is 7.},
    solution: ~S{Date.day_of_week(input)},
    checks: [
      {~S{~D[2024-01-01]}, ~S{1}},
      {~S{~D[2024-03-03]}, ~S{7}},
      {~S{~D[2024-02-29]}, ~S{4}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/day-of-year",
    prompt:
      ~S{`input` is a `Date`. Return which day of its year it is, as an integer (January 1st is 1).},
    solution: ~S{Date.day_of_year(input)},
    checks: [
      {~S{~D[2024-01-01]}, ~S{1}},
      {~S{~D[2024-12-31]}, ~S{366}},
      {~S{~D[2023-12-31]}, ~S{365}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/days-in-month",
    prompt:
      ~S{`input` is a `Date`. Return the number of days in the month that date falls in, as an integer.},
    solution: ~S{Date.days_in_month(input)},
    checks: [
      {~S{~D[2024-02-10]}, ~S{29}},
      {~S{~D[2023-02-10]}, ~S{28}},
      {~S{~D[2024-04-01]}, ~S{30}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/leap-year",
    prompt:
      ~S{`input` is a `Date`. Return a boolean: `true` exactly when the date's year is a leap year.},
    solution: ~S{Date.leap_year?(input)},
    checks: [
      {~S{~D[2024-06-01]}, ~S{true}},
      {~S{~D[1900-06-01]}, ~S{false}},
      {~S{~D[2000-06-01]}, ~S{true}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/beginning-of-month",
    prompt: ~S{`input` is a `Date`. Return the first day of that date's month, as a `Date`.},
    solution: ~S{Date.beginning_of_month(input)},
    checks: [
      {~S{~D[2024-02-29]}, ~S{~D[2024-02-01]}},
      {~S{~D[2024-01-01]}, ~S{~D[2024-01-01]}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/end-of-month",
    prompt: ~S{`input` is a `Date`. Return the last day of that date's month, as a `Date`.},
    solution: ~S{Date.end_of_month(input)},
    checks: [
      {~S{~D[2024-02-01]}, ~S{~D[2024-02-29]}},
      {~S{~D[2023-02-15]}, ~S{~D[2023-02-28]}},
      {~S{~D[2024-04-10]}, ~S{~D[2024-04-30]}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/beginning-of-week",
    prompt:
      ~S{`input` is a `Date`. Return the date of the Monday of the week containing `input` (weeks run Monday through Sunday), as a `Date`.},
    solution: ~S{Date.beginning_of_week(input)},
    checks: [
      {~S{~D[2024-02-29]}, ~S{~D[2024-02-26]}},
      {~S{~D[2024-01-01]}, ~S{~D[2024-01-01]}},
      {~S{~D[2024-03-03]}, ~S{~D[2024-02-26]}}
    ],
    tags: [:date],
    difficulty: :medium
  },
  %{
    id: "datetime/range-count",
    prompt:
      ~S|`input` is a tuple `{first, last}` of two `Date` structs with `first <= last` chronologically. Return how many calendar dates the inclusive range from `first` to `last` contains, as an integer.|,
    solution: ~S{Date.range(elem(input, 0), elem(input, 1)) |> Enum.count()},
    checks: [
      {~S|{~D[2024-02-01], ~D[2024-02-29]}|, ~S{29}},
      {~S|{~D[2024-05-05], ~D[2024-05-05]}|, ~S{1}}
    ],
    tags: [:date],
    difficulty: :medium
  },
  %{
    id: "datetime/range-step",
    prompt:
      ~S|`input` is a tuple `{first, last}` of two `Date` structs with `first <= last`. Return the list of every 3rd date starting at `first` and never passing `last` (so `first` is always included), as a list of `Date` structs in ascending order.|,
    solution: ~S{Date.range(elem(input, 0), elem(input, 1), 3) |> Enum.to_list()},
    checks: [
      {~S|{~D[2024-01-01], ~D[2024-01-10]}|,
       ~S{[~D[2024-01-01], ~D[2024-01-04], ~D[2024-01-07], ~D[2024-01-10]]}},
      {~S|{~D[2024-01-01], ~D[2024-01-01]}|, ~S{[~D[2024-01-01]]}}
    ],
    tags: [:date],
    difficulty: :medium
  },
  %{
    id: "datetime/shift-month-clamp",
    prompt:
      ~S{`input` is a `Date`. Return the date one calendar month later, as a `Date`. When the day does not exist in the target month, clamp to that month's last day (e.g. January 31st becomes the last day of February).},
    solution: ~S{Date.shift(input, month: 1)},
    checks: [
      {~S{~D[2024-01-31]}, ~S{~D[2024-02-29]}},
      {~S{~D[2023-01-31]}, ~S{~D[2023-02-28]}},
      {~S{~D[2024-02-15]}, ~S{~D[2024-03-15]}}
    ],
    tags: [:date, :drift, :trap],
    difficulty: :hard
  },
  %{
    id: "datetime/shift-month-back",
    prompt:
      ~S{`input` is a `Date`. Return the date one calendar month earlier, as a `Date`, clamping to the last day of the previous month when the day does not exist there.},
    solution: ~S{Date.shift(input, month: -1)},
    checks: [
      {~S{~D[2024-03-31]}, ~S{~D[2024-02-29]}},
      {~S{~D[2024-01-15]}, ~S{~D[2023-12-15]}}
    ],
    tags: [:date, :drift],
    difficulty: :hard
  },
  %{
    id: "datetime/shift-week",
    prompt: ~S{`input` is a `Date`. Return the date exactly two weeks later, as a `Date`.},
    solution: ~S{Date.shift(input, week: 2)},
    checks: [
      {~S{~D[2024-01-01]}, ~S{~D[2024-01-15]}},
      {~S{~D[2024-02-26]}, ~S{~D[2024-03-11]}}
    ],
    tags: [:date, :drift],
    difficulty: :medium
  },
  %{
    id: "datetime/time-add-wrap",
    prompt:
      ~S{`input` is a `Time`. Return the time 90 minutes later, as a `Time`. Times wrap around midnight (23:00:00 plus 90 minutes is 00:30:00).},
    solution: ~S{Time.add(input, 90, :minute)},
    checks: [
      {~S{~T[23:00:00]}, ~S{~T[00:30:00]}},
      {~S{~T[10:15:00]}, ~S{~T[11:45:00]}}
    ],
    tags: [:time, :gotcha],
    difficulty: :medium
  },
  %{
    id: "datetime/time-sub-wrap",
    prompt:
      ~S{`input` is a `Time`. Return the time one second earlier, as a `Time`. Times wrap around midnight (one second before 00:00:00 is 23:59:59).},
    solution: ~S{Time.add(input, -1)},
    checks: [
      {~S{~T[00:00:00]}, ~S{~T[23:59:59]}},
      {~S{~T[12:00:00]}, ~S{~T[11:59:59]}}
    ],
    tags: [:time, :gotcha],
    difficulty: :hard
  },
  %{
    id: "datetime/time-diff",
    prompt:
      ~S|`input` is a tuple `{t1, t2}` of two `Time` structs (times of the same day). Return `t1` minus `t2` in whole seconds as an integer (negative when `t1` is earlier in the day than `t2`).|,
    solution: ~S{Time.diff(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{~T[01:00:00], ~T[00:30:00]}|, ~S{1800}},
      {~S|{~T[00:10:00], ~T[23:50:00]}|, ~S{-85200}}
    ],
    tags: [:time],
    difficulty: :easy
  },
  %{
    id: "datetime/time-truncate",
    prompt:
      ~S{`input` is a `Time`, possibly with sub-second precision. Return the same time truncated to whole seconds, with the sub-second part (and its precision) removed entirely, as a `Time`.},
    solution: ~S{Time.truncate(input, :second)},
    checks: [
      {~S{~T[12:30:45.123456]}, ~S{~T[12:30:45]}},
      {~S{~T[00:00:00]}, ~S{~T[00:00:00]}}
    ],
    tags: [:time],
    difficulty: :medium
  },
  %{
    id: "datetime/ndt-add-seconds",
    prompt:
      ~S{`input` is a `NaiveDateTime`. Return the naive datetime exactly one second later, as a `NaiveDateTime`.},
    solution: ~S{NaiveDateTime.add(input, 1)},
    checks: [
      {~S{~N[2024-12-31 23:59:59]}, ~S{~N[2025-01-01 00:00:00]}},
      {~S{~N[2024-02-28 23:59:59]}, ~S{~N[2024-02-29 00:00:00]}}
    ],
    tags: [:naive_datetime],
    difficulty: :easy
  },
  %{
    id: "datetime/ndt-diff",
    prompt:
      ~S|`input` is a tuple `{a, b}` of two `NaiveDateTime` structs. Return `a` minus `b` in whole seconds as an integer (negative when `a` is before `b`).|,
    solution: ~S{NaiveDateTime.diff(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{~N[2024-01-01 01:00:00], ~N[2024-01-01 00:00:00]}|, ~S{3600}},
      {~S|{~N[2024-01-01 00:00:00], ~N[2024-01-01 00:00:30]}|, ~S{-30}}
    ],
    tags: [:naive_datetime],
    difficulty: :easy
  },
  %{
    id: "datetime/ndt-truncate",
    prompt:
      ~S{`input` is a `NaiveDateTime`, possibly with sub-second precision. Return it truncated to whole seconds, with the sub-second part (and its precision) removed entirely, as a `NaiveDateTime`.},
    solution: ~S{NaiveDateTime.truncate(input, :second)},
    checks: [
      {~S{~N[2024-01-01 12:30:45.123456]}, ~S{~N[2024-01-01 12:30:45]}},
      {~S{~N[2024-01-01 00:00:00]}, ~S{~N[2024-01-01 00:00:00]}}
    ],
    tags: [:naive_datetime],
    difficulty: :medium
  },
  %{
    id: "datetime/dt-from-naive",
    prompt:
      ~S{`input` is a `NaiveDateTime`. Return the corresponding `DateTime` in the "Etc/UTC" time zone (raising on failure is fine; the inputs are always valid).},
    solution: ~S{DateTime.from_naive!(input, "Etc/UTC")},
    checks: [
      {~S{~N[2024-02-29 12:00:00]}, ~S{~U[2024-02-29 12:00:00Z]}},
      {~S{~N[1970-01-01 00:00:00]}, ~S{~U[1970-01-01 00:00:00Z]}}
    ],
    tags: [:datetime],
    difficulty: :medium
  },
  %{
    id: "datetime/dt-to-unix",
    prompt:
      ~S{`input` is a UTC `DateTime`. Return its Unix timestamp in whole seconds, as an integer.},
    solution: ~S{DateTime.to_unix(input)},
    checks: [
      {~S{~U[2024-01-01 00:00:00Z]}, ~S{1704067200}},
      {~S{~U[1970-01-01 00:00:01Z]}, ~S{1}}
    ],
    tags: [:datetime],
    difficulty: :easy
  },
  %{
    id: "datetime/unix-to-date",
    prompt:
      ~S{`input` is an integer Unix timestamp in seconds. Return the UTC calendar date of that instant, as a `Date`.},
    solution: ~S{DateTime.from_unix!(input) |> DateTime.to_date()},
    checks: [
      {~S{1704067200}, ~S{~D[2024-01-01]}},
      {~S{0}, ~S{~D[1970-01-01]}},
      {~S{1709164800}, ~S{~D[2024-02-29]}}
    ],
    tags: [:datetime, :trap],
    difficulty: :hard
  },
  %{
    id: "datetime/dt-add-day",
    prompt:
      ~S{`input` is a UTC `DateTime`. Return the datetime exactly one day (24 hours) later, as a `DateTime`.},
    solution: ~S{DateTime.add(input, 1, :day)},
    checks: [
      {~S{~U[2024-02-28 12:00:00Z]}, ~S{~U[2024-02-29 12:00:00Z]}},
      {~S{~U[2024-12-31 23:00:00Z]}, ~S{~U[2025-01-01 23:00:00Z]}}
    ],
    tags: [:datetime],
    difficulty: :easy
  },
  %{
    id: "datetime/strftime-iso",
    prompt:
      ~S{`input` is a `Date`. Return it formatted as a string in "YYYY-MM-DD" form with zero-padded month and day.},
    solution: ~S{Calendar.strftime(input, "%Y-%m-%d")},
    checks: [
      {~S{~D[2024-02-29]}, ~S{"2024-02-29"}},
      {~S{~D[2024-03-05]}, ~S{"2024-03-05"}}
    ],
    tags: [:calendar],
    difficulty: :medium
  },
  %{
    id: "datetime/strftime-names",
    prompt:
      ~S{`input` is a `Date`. Return a string with its full English weekday name, a single space, and its full English month name (for example "Monday January").},
    solution: ~S{Calendar.strftime(input, "%A %B")},
    checks: [
      {~S{~D[2024-02-29]}, ~S{"Thursday February"}},
      {~S{~D[2024-01-01]}, ~S{"Monday January"}}
    ],
    tags: [:calendar],
    difficulty: :medium
  },
  %{
    id: "datetime/date-to-iso",
    prompt: ~S{`input` is a `Date`. Return its ISO 8601 string representation.},
    solution: ~S{Date.to_iso8601(input)},
    checks: [
      {~S{~D[2024-02-29]}, ~S{"2024-02-29"}},
      {~S{~D[1970-01-01]}, ~S{"1970-01-01"}}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/date-from-iso",
    prompt:
      ~S|`input` is a string. Parse it as an ISO 8601 date and return the stdlib result tuple unchanged: `{:ok, date}` on success or `{:error, reason}` on failure.|,
    solution: ~S{Date.from_iso8601(input)},
    checks: [
      {~S{"2024-02-29"}, ~S|{:ok, ~D[2024-02-29]}|},
      {~S{"not-a-date"}, ~S|{:error, :invalid_format}|},
      {~S{"2023-02-29"}, ~S|{:error, :invalid_date}|}
    ],
    tags: [:date],
    difficulty: :easy
  },
  %{
    id: "datetime/date-from-iso-bang",
    prompt:
      ~S{`input` is a string. Parse it as an ISO 8601 date and return the `Date` directly, raising `ArgumentError` when the string is not a valid date.},
    solution: ~S{Date.from_iso8601!(input)},
    checks: [
      {~S{"2024-02-29"}, ~S{~D[2024-02-29]}},
      {~S{"1970-01-01"}, ~S{~D[1970-01-01]}}
    ],
    raw_checks: [
      ~S{assert_raise ArgumentError, fn -> Micro.solve("2024-13-01") end}
    ],
    tags: [:date],
    difficulty: :medium
  },
  %{
    id: "datetime/duration-new",
    prompt:
      ~S{`input` is a keyword list of duration unit pairs, e.g. `[hour: 2, minute: 30]`. Return the corresponding `Duration` struct, raising on invalid units (the inputs are always valid).},
    solution: ~S{Duration.new!(input)},
    checks: [
      {~S{[hour: 2, minute: 30]}, ~S{Duration.new!(hour: 2, minute: 30)}},
      {~S{[week: 1]}, ~S{Duration.new!(week: 1)}},
      {~S{[month: 1, day: -3]}, ~S{Duration.new!(month: 1, day: -3)}}
    ],
    tags: [:duration, :drift],
    difficulty: :medium
  },
  %{
    id: "datetime/duration-add",
    prompt:
      ~S|`input` is a tuple `{d1, d2}` of two `Duration` structs. Return their unit-wise sum as a `Duration` (each field added independently, no unit conversion).|,
    solution: ~S{Duration.add(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{Duration.new!(hour: 1), Duration.new!(minute: 30)}|,
       ~S{Duration.new!(hour: 1, minute: 30)}},
      {~S|{Duration.new!(hour: 2), Duration.new!(hour: -1, minute: 15)}|,
       ~S{Duration.new!(hour: 1, minute: 15)}}
    ],
    tags: [:duration, :drift],
    difficulty: :medium
  },
  %{
    id: "datetime/duration-multiply",
    prompt:
      ~S|`input` is a tuple `{duration, k}` of a `Duration` struct and an integer. Return the duration with every unit multiplied by `k`, as a `Duration`.|,
    solution: ~S{Duration.multiply(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{Duration.new!(day: 2), 3}|, ~S{Duration.new!(day: 6)}},
      {~S|{Duration.new!(hour: 3), -1}|, ~S{Duration.new!(hour: -3)}}
    ],
    tags: [:duration, :drift],
    difficulty: :medium
  },
  %{
    id: "datetime/to-timeout",
    prompt:
      ~S{`input` is a single-pair keyword list naming a time unit, e.g. `[minute: 1]`. Return that span converted to a timeout in milliseconds, as an integer.},
    solution: ~S{to_timeout(input)},
    checks: [
      {~S{[minute: 1]}, ~S{60_000}},
      {~S{[second: 90]}, ~S{90_000}},
      {~S{[hour: 1]}, ~S{3_600_000}}
    ],
    tags: [:kernel, :drift],
    difficulty: :medium
  },
  %{
    id: "datetime/earlier-date",
    prompt:
      ~S|`input` is a tuple `{a, b}` of two `Date` structs. Return whichever date is chronologically earlier (either one when they are equal), as a `Date`.|,
    solution: ~S{Enum.min(Tuple.to_list(input), Date)},
    checks: [
      {~S|{~D[2024-02-01], ~D[2024-01-31]}|, ~S{~D[2024-01-31]}},
      {~S|{~D[2023-06-10], ~D[2024-06-10]}|, ~S{~D[2023-06-10]}},
      {~S|{~D[2024-05-05], ~D[2024-05-05]}|, ~S{~D[2024-05-05]}}
    ],
    tags: [:date, :gotcha],
    difficulty: :hard
  },
  %{
    id: "datetime/sort-dates",
    prompt:
      ~S{`input` is a list of `Date` structs. Return them sorted in ascending chronological order, as a list of `Date` structs.},
    solution: ~S{Enum.sort(input, Date)},
    checks: [
      {~S{[~D[2024-01-15], ~D[2023-12-31], ~D[2024-02-01]]},
       ~S{[~D[2023-12-31], ~D[2024-01-15], ~D[2024-02-01]]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:date, :gotcha],
    difficulty: :hard
  },
  %{
    id: "datetime/naive-to-unix",
    prompt:
      ~S{`input` is a `NaiveDateTime`. Interpreting it as a UTC wall-clock time, return its Unix timestamp in whole seconds, as an integer.},
    solution: ~S{DateTime.from_naive!(input, "Etc/UTC") |> DateTime.to_unix()},
    checks: [
      {~S{~N[2024-01-01 00:00:00]}, ~S{1704067200}},
      {~S{~N[1970-01-01 00:00:01]}, ~S{1}}
    ],
    tags: [:datetime, :trap],
    difficulty: :hard
  },

  # ── access ──────────────────────────────────────────────────────────────
  %{
    id: "access/get-in-basic",
    prompt:
      ~S|`input` is a map nested three levels deep with atom keys, e.g. `%{a: %{b: %{c: 42}}}`. Return the value stored at the path `:a`, then `:b`, then `:c`.|,
    solution: ~S{get_in(input, [:a, :b, :c])},
    checks: [
      {~S|%{a: %{b: %{c: 42}}}|, ~S{42}},
      {~S|%{a: %{b: %{c: "deep"}, x: 1}}|, ~S{"deep"}}
    ],
    tags: [:access],
    difficulty: :easy
  },
  %{
    id: "access/get-in-missing",
    prompt:
      ~S{`input` is a map with atom keys. Return the value at the path `:a` then `:b`; when `:a` or `:b` is missing anywhere along the path the result must be `nil`, never an error.},
    solution: ~S{get_in(input, [:a, :b])},
    checks: [
      {~S|%{a: %{b: 1}}|, ~S{1}},
      {~S|%{}|, ~S{nil}},
      {~S|%{x: 1}|, ~S{nil}}
    ],
    tags: [:access, :gotcha],
    difficulty: :medium
  },
  %{
    id: "access/put-in",
    prompt:
      ~S|`input` is a map whose `:a` key holds a map. Return `input` with the value `0` stored under `:b` inside that inner map (inserting `:b` if absent), leaving everything else unchanged.|,
    solution: ~S{put_in(input, [:a, :b], 0)},
    checks: [
      {~S|%{a: %{b: 5}}|, ~S|%{a: %{b: 0}}|},
      {~S|%{a: %{b: 5, c: 1}}|, ~S|%{a: %{b: 0, c: 1}}|},
      {~S|%{a: %{}}|, ~S|%{a: %{b: 0}}|}
    ],
    tags: [:access],
    difficulty: :easy
  },
  %{
    id: "access/update-in",
    prompt:
      ~S{`input` is a map whose `:a` key holds a map with an integer under `:b`. Return `input` with that integer incremented by 1, leaving everything else unchanged.},
    solution: ~S{update_in(input, [:a, :b], &(&1 + 1))},
    checks: [
      {~S|%{a: %{b: 9}}|, ~S|%{a: %{b: 10}}|},
      {~S|%{a: %{b: -1}, x: 0}|, ~S|%{a: %{b: 0}, x: 0}|}
    ],
    tags: [:access],
    difficulty: :easy
  },
  %{
    id: "access/get-and-update-in",
    prompt:
      ~S|`input` is a map whose `:a` key holds a map with an integer under `:b`. Return a tuple `{old, updated}` where `old` is the current integer at that path and `updated` is `input` with that integer doubled.|,
    solution: ~S|get_and_update_in(input, [:a, :b], fn v -> {v, v * 2} end)|,
    checks: [
      {~S|%{a: %{b: 3}}|, ~S|{3, %{a: %{b: 6}}}|},
      {~S|%{a: %{b: 0}}|, ~S|{0, %{a: %{b: 0}}}|}
    ],
    tags: [:access],
    difficulty: :medium
  },
  %{
    id: "access/pop-in",
    prompt:
      ~S|`input` is a map whose `:a` key holds a map. Remove the `:b` key from that inner map and return the tuple `{popped_value, remaining_data}`; when `:b` is absent the popped value is `nil` and the data is unchanged.|,
    solution: ~S{pop_in(input, [:a, :b])},
    checks: [
      {~S|%{a: %{b: 1, c: 2}}|, ~S|{1, %{a: %{c: 2}}}|},
      {~S|%{a: %{c: 2}}|, ~S|{nil, %{a: %{c: 2}}}|}
    ],
    tags: [:access],
    difficulty: :medium
  },
  %{
    id: "access/key-default",
    prompt:
      ~S|`input` is a map. Return the value at the path `:a` then `:b`, where a missing `:a` is treated as an empty map and a missing `:b` yields the default `0` (so the result is never `nil`).|,
    solution: ~S|get_in(input, [Access.key(:a, %{}), Access.key(:b, 0)])|,
    checks: [
      {~S|%{a: %{b: 7}}|, ~S{7}},
      {~S|%{a: %{}}|, ~S{0}},
      {~S|%{}|, ~S{0}}
    ],
    tags: [:access],
    difficulty: :medium
  },
  %{
    id: "access/key-bang-struct",
    prompt:
      ~S{`input` is a `Date` struct. Return its `:month` field using a `get_in` path (note: plain atom keys in a path do not work on structs; you need an accessor that reaches into struct fields).},
    solution: ~S{get_in(input, [Access.key!(:month)])},
    checks: [
      {~S{~D[2024-02-29]}, ~S{2}},
      {~S{~D[2024-12-01]}, ~S{12}}
    ],
    tags: [:access, :gotcha],
    difficulty: :hard
  },
  %{
    id: "access/at",
    prompt:
      ~S|`input` is a map whose `:items` key holds a list. Using a single access path, return the element at index 1 (zero-based) of that list, or `nil` when the list is too short.|,
    solution: ~S{get_in(input, [:items, Access.at(1)])},
    checks: [
      {~S|%{items: [1, 2, 3]}|, ~S{2}},
      {~S|%{items: [1]}|, ~S{nil}}
    ],
    tags: [:access],
    difficulty: :easy
  },
  %{
    id: "access/at-negative",
    prompt:
      ~S{`input` is a list. Using an access path (not `List.last`), return its last element, or `nil` for an empty list.},
    solution: ~S{get_in(input, [Access.at(-1)])},
    checks: [
      {~S{[1, 2, 3]}, ~S{3}},
      {~S{[]}, ~S{nil}}
    ],
    tags: [:access],
    difficulty: :medium
  },
  %{
    id: "access/all-update",
    prompt:
      ~S|`input` is a map whose `:nums` key holds a list of integers. Return `input` with every element of that list incremented by 1.|,
    solution: ~S{update_in(input, [:nums, Access.all()], &(&1 + 1))},
    checks: [
      {~S|%{nums: [1, 2]}|, ~S|%{nums: [2, 3]}|},
      {~S|%{nums: []}|, ~S|%{nums: []}|}
    ],
    tags: [:access],
    difficulty: :medium
  },
  %{
    id: "access/all-pluck",
    prompt:
      ~S{`input` is a list of maps. Return the list of each map's `:name` value, in order; maps without a `:name` key contribute `nil`.},
    solution: ~S{get_in(input, [Access.all(), :name])},
    checks: [
      {~S|[%{name: "ada"}, %{name: "bob"}]|, ~S{["ada", "bob"]}},
      {~S{[]}, ~S{[]}},
      {~S|[%{name: "x"}, %{}]|, ~S{["x", nil]}}
    ],
    tags: [:access],
    difficulty: :medium
  },
  %{
    id: "access/filter-update",
    prompt:
      ~S{`input` is a list of integers. Return the list with every even element multiplied by 10 and every odd element left untouched, preserving order.},
    solution: ~S{update_in(input, [Access.filter(&(rem(&1, 2) == 0))], &(&1 * 10))},
    checks: [
      {~S{[1, 2, 3, 4]}, ~S{[1, 20, 3, 40]}},
      {~S{[]}, ~S{[]}},
      {~S{[1, 3]}, ~S{[1, 3]}}
    ],
    tags: [:access],
    difficulty: :hard
  },
  %{
    id: "access/elem",
    prompt:
      ~S|`input` is a list of two-element tuples like `{name, score}`. Using a single access path over the list, return the list of first tuple elements (the names), in order.|,
    solution: ~S{get_in(input, [Access.all(), Access.elem(0)])},
    checks: [
      {~S|[{"a", 1}, {"b", 2}]|, ~S{["a", "b"]}},
      {~S{[]}, ~S{[]}}
    ],
    tags: [:access],
    difficulty: :medium
  },
  %{
    id: "access/slice",
    prompt:
      ~S{`input` is a list. Using an access path, return the elements at indices 1 through 3 inclusive (zero-based) as a list; indices beyond the end are simply omitted.},
    solution: ~S{get_in(input, [Access.slice(1..3)])},
    checks: [
      {~S{[1, 2, 3, 4, 5]}, ~S{[2, 3, 4]}},
      {~S{[1, 2]}, ~S{[2]}},
      {~S{[1]}, ~S{[]}}
    ],
    tags: [:access],
    difficulty: :hard
  },
  %{
    id: "access/map-bracket",
    prompt:
      ~S{`input` is a map with atom keys. Return the value under `:count`, or `nil` when the key is absent (no error).},
    solution: ~S{input[:count]},
    checks: [
      {~S|%{count: 3}|, ~S{3}},
      {~S|%{}|, ~S{nil}}
    ],
    tags: [:access],
    difficulty: :easy
  },
  %{
    id: "access/keyword-bracket",
    prompt:
      ~S{`input` is a keyword list. Return the value for the key `:b`: `nil` when absent, and the first occurrence when the key appears more than once.},
    solution: ~S{input[:b]},
    checks: [
      {~S{[a: 1, b: 2]}, ~S{2}},
      {~S{[a: 1]}, ~S{nil}},
      {~S{[b: 5, b: 9]}, ~S{5}}
    ],
    tags: [:access],
    difficulty: :easy
  },
  %{
    id: "access/nil-propagation",
    prompt:
      ~S{`input` is a map whose `:a` key holds either a map or `nil`. Return the value at the path `:a` then `:b`; when `:a` holds `nil` the result must be `nil`, never an error.},
    solution: ~S{get_in(input, [:a, :b])},
    checks: [
      {~S|%{a: %{b: 3}}|, ~S{3}},
      {~S|%{a: nil}|, ~S{nil}}
    ],
    tags: [:access, :gotcha],
    difficulty: :medium
  },
  %{
    id: "access/values-update",
    prompt:
      ~S{`input` is a map with integer values. Return the map with every value doubled (keys unchanged).},
    solution: ~S{update_in(input, [Access.values()], &(&1 * 2))},
    checks: [
      {~S|%{a: 1, b: 2}|, ~S|%{a: 2, b: 4}|},
      {~S|%{}|, ~S|%{}|}
    ],
    tags: [:access, :drift],
    difficulty: :medium
  },
  %{
    id: "access/values-nested",
    prompt:
      ~S|`input` is a map whose values are maps, each holding an integer under `:n` (e.g. `%{a: %{n: 1}, b: %{n: 2}}`). Return `input` with every `:n` incremented by 1, using a single expression.|,
    solution: ~S{update_in(input, [Access.values(), :n], &(&1 + 1))},
    checks: [
      {~S|%{a: %{n: 1}, b: %{n: 2}}|, ~S|%{a: %{n: 2}, b: %{n: 3}}|},
      {~S|%{}|, ~S|%{}|}
    ],
    tags: [:access, :drift],
    difficulty: :hard
  },
  %{
    id: "access/map-path",
    prompt:
      ~S|`input` is a tuple `{data, path}` where `data` is a nested map with atom keys and `path` is a list of atom keys. Return the value found by following `path` into `data`, or `nil` when any key along the way is missing.|,
    solution: ~S{get_in(elem(input, 0), elem(input, 1))},
    checks: [
      {~S|{%{a: %{b: 1}}, [:a, :b]}|, ~S{1}},
      {~S|{%{a: 1}, [:z]}|, ~S{nil}}
    ],
    tags: [:access, :trap],
    difficulty: :medium
  },
  %{
    id: "access/struct-bracket",
    prompt:
      ~S{`input` is either a plain map or a struct. Return the value under the `:year` key using dynamic bracket access — the kind where a missing map key yields `nil`, and where structs (which do not implement the Access behaviour) raise `UndefinedFunctionError`. Do not special-case structs; let the raise happen.},
    solution: ~S{input[:year]},
    checks: [
      {~S|%{year: 1999}|, ~S{1999}},
      {~S|%{}|, ~S{nil}}
    ],
    raw_checks: [
      ~S{assert_raise UndefinedFunctionError, fn -> Micro.solve(~D[2024-01-01]) end}
    ],
    tags: [:access, :gotcha, :trap],
    difficulty: :hard
  }
]
