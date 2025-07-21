
flutter: Starting _showAddEventDialog
flutter: About to show AddEditEventDialog
flutter: DEBUG - Final CustomRecurrence before save: null
flutter: DEBUG - Before save:
flutter: DEBUG - selectedDate: 2025-07-21 00:00:00.000Z
flutter: DEBUG - adjustedDate: 2025-07-21 00:00:00.000Z
flutter: DEBUG - repeatOption: RepeatOption.today
flutter: Dialog result: event created
flutter: 🔍 DEBUG: EventService.addEvent called - Title: Test, Amount: $100.0, IsRecurring: false
flutter: 🔍 DEBUG: Non-recurring event, calling regular addEvent...
flutter: Creating event with customRecurrence: Value(null)
flutter: Event created with ID: 8169
flutter: Event after update - ID: 8169, OriginalID: 8169
flutter: Created event verification - ID: 8169, OriginalID: 8169
flutter: Event added successfully
flutter: UI requesting events for 2025-07-01 00:00:00.000: found 0 events

flutter: Starting _showAddEventDialog
flutter: About to show AddEditEventDialog
flutter: DEBUG - Custom Recurrence set to: {interval: daily, frequency: 1, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null}
flutter: DEBUG - Frequency: 1
flutter: DEBUG - Updated frequency to: 3
flutter: DEBUG - Custom Recurrence: {interval: daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null}
flutter: DEBUG - Final CustomRecurrence before save: {interval: daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null}
flutter: DEBUG - Before save:
flutter: DEBUG - selectedDate: 2025-07-23 00:00:00.000Z
flutter: DEBUG - adjustedDate: 2025-07-23 00:00:00.000Z
flutter: DEBUG - repeatOption: RepeatOption.daily
flutter: DEBUG - selectedDays: [false, false, false, false, false, false, false]
flutter: DEBUG - selectedDayIndices: []
flutter: Dialog result: event created
flutter: 🔍 DEBUG: EventNotifier._addRecurringEvent called - Title: Cvcv, Amount: $200.0
flutter: 🔍 DEBUG: StartDay: 2025-07-23T00:00:00.000Z, RepeatOption: RepeatOption.daily
flutter: 🔍 DEBUG: EventService.addEvent called - Title: Cvcv, Amount: $200.0, IsRecurring: true
flutter: 🔍 DEBUG: Detected recurring event, calling addRecurringEvent...
flutter: 🔍 DEBUG: addRecurringEvent called for Cvcv ($200.0) starting 2025-07-23
flutter: 🔍 DEBUG: _generateRecurringEvents called for: Cvcv, startDate: 2025-07-23T00:00:00.000Z
flutter: 🔍 DEBUG: Event details - Amount: $200.0, RepeatOption: RepeatOption.daily, CustomRecurrence: 3
flutter: 🔍 DEBUG: First occurrence calculated as: 2025-07-23T00:00:00.000Z
flutter: 🔍 DEBUG: Creating first event in database...
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8170
flutter: Event after update - ID: 8170, OriginalID: 8170
flutter: 🔍 DEBUG: First event created with ID: 8170, Date: 2025-07-23T00:00:00.000Z, OriginalEventId: 8170
flutter: 🔍 DEBUG: Creating event #2 for date: 2025-07-26T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8171
flutter: Event after update - ID: 8171, OriginalID: 8170
flutter: 🔍 DEBUG: Event #2 created with ID: 8171
flutter: 🔍 DEBUG: Creating event #3 for date: 2025-07-29T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8172
flutter: Event after update - ID: 8172, OriginalID: 8170
flutter: 🔍 DEBUG: Event #3 created with ID: 8172
flutter: 🔍 DEBUG: Creating event #4 for date: 2025-08-01T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8173
flutter: Event after update - ID: 8173, OriginalID: 8170
flutter: 🔍 DEBUG: Event #4 created with ID: 8173
flutter: 🔍 DEBUG: Creating event #5 for date: 2025-08-04T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8174
flutter: Event after update - ID: 8174, OriginalID: 8170
flutter: 🔍 DEBUG: Event #5 created with ID: 8174
flutter: 🔍 DEBUG: Creating event #6 for date: 2025-08-07T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8175
flutter: Event after update - ID: 8175, OriginalID: 8170
flutter: 🔍 DEBUG: Event #6 created with ID: 8175
flutter: 🔍 DEBUG: Creating event #7 for date: 2025-08-10T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8176
flutter: Event after update - ID: 8176, OriginalID: 8170
flutter: 🔍 DEBUG: Event #7 created with ID: 8176
flutter: 🔍 DEBUG: Creating event #8 for date: 2025-08-13T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8177
flutter: Event after update - ID: 8177, OriginalID: 8170
flutter: 🔍 DEBUG: Event #8 created with ID: 8177
flutter: 🔍 DEBUG: Creating event #9 for date: 2025-08-16T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8178
flutter: Event after update - ID: 8178, OriginalID: 8170
flutter: 🔍 DEBUG: Event #9 created with ID: 8178
flutter: 🔍 DEBUG: Creating event #10 for date: 2025-08-19T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8179
flutter: Event after update - ID: 8179, OriginalID: 8170
flutter: 🔍 DEBUG: Event #10 created with ID: 8179
flutter: 🔍 DEBUG: Creating event #11 for date: 2025-08-22T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8180
flutter: Event after update - ID: 8180, OriginalID: 8170
flutter: 🔍 DEBUG: Event #11 created with ID: 8180
flutter: 🔍 DEBUG: Creating event #12 for date: 2025-08-25T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8181
flutter: Event after update - ID: 8181, OriginalID: 8170
flutter: 🔍 DEBUG: Event #12 created with ID: 8181
flutter: 🔍 DEBUG: Creating event #13 for date: 2025-08-28T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8182
flutter: Event after update - ID: 8182, OriginalID: 8170
flutter: 🔍 DEBUG: Event #13 created with ID: 8182
flutter: 🔍 DEBUG: Creating event #14 for date: 2025-08-31T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8183
flutter: Event after update - ID: 8183, OriginalID: 8170
flutter: 🔍 DEBUG: Event #14 created with ID: 8183
flutter: 🔍 DEBUG: Creating event #15 for date: 2025-09-03T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8184
flutter: Event after update - ID: 8184, OriginalID: 8170
flutter: 🔍 DEBUG: Event #15 created with ID: 8184
flutter: 🔍 DEBUG: Creating event #16 for date: 2025-09-06T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8185
flutter: Event after update - ID: 8185, OriginalID: 8170
flutter: 🔍 DEBUG: Event #16 created with ID: 8185
flutter: 🔍 DEBUG: Creating event #17 for date: 2025-09-09T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8186
flutter: Event after update - ID: 8186, OriginalID: 8170
flutter: 🔍 DEBUG: Event #17 created with ID: 8186
flutter: 🔍 DEBUG: Creating event #18 for date: 2025-09-12T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8187
flutter: Event after update - ID: 8187, OriginalID: 8170
flutter: 🔍 DEBUG: Event #18 created with ID: 8187
flutter: 🔍 DEBUG: Creating event #19 for date: 2025-09-15T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8188
flutter: Event after update - ID: 8188, OriginalID: 8170
flutter: 🔍 DEBUG: Event #19 created with ID: 8188
flutter: 🔍 DEBUG: Creating event #20 for date: 2025-09-18T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8189
flutter: Event after update - ID: 8189, OriginalID: 8170
flutter: 🔍 DEBUG: Event #20 created with ID: 8189
flutter: 🔍 DEBUG: Creating event #21 for date: 2025-09-21T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8190
flutter: Event after update - ID: 8190, OriginalID: 8170
flutter: 🔍 DEBUG: Event #21 created with ID: 8190
flutter: 🔍 DEBUG: Creating event #22 for date: 2025-09-24T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8191
flutter: Event after update - ID: 8191, OriginalID: 8170
flutter: 🔍 DEBUG: Event #22 created with ID: 8191
flutter: 🔍 DEBUG: Creating event #23 for date: 2025-09-27T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8192
flutter: Event after update - ID: 8192, OriginalID: 8170
flutter: 🔍 DEBUG: Event #23 created with ID: 8192
flutter: 🔍 DEBUG: Creating event #24 for date: 2025-09-30T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8193
flutter: Event after update - ID: 8193, OriginalID: 8170
flutter: 🔍 DEBUG: Event #24 created with ID: 8193
flutter: 🔍 DEBUG: Creating event #25 for date: 2025-10-03T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8194
flutter: Event after update - ID: 8194, OriginalID: 8170
flutter: 🔍 DEBUG: Event #25 created with ID: 8194
flutter: 🔍 DEBUG: Creating event #26 for date: 2025-10-06T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8195
flutter: Event after update - ID: 8195, OriginalID: 8170
flutter: 🔍 DEBUG: Event #26 created with ID: 8195
flutter: 🔍 DEBUG: Creating event #27 for date: 2025-10-09T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8196
flutter: Event after update - ID: 8196, OriginalID: 8170
flutter: 🔍 DEBUG: Event #27 created with ID: 8196
flutter: 🔍 DEBUG: Creating event #28 for date: 2025-10-12T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8197
flutter: Event after update - ID: 8197, OriginalID: 8170
flutter: 🔍 DEBUG: Event #28 created with ID: 8197
flutter: 🔍 DEBUG: Creating event #29 for date: 2025-10-15T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8198
flutter: Event after update - ID: 8198, OriginalID: 8170
flutter: 🔍 DEBUG: Event #29 created with ID: 8198
flutter: 🔍 DEBUG: Creating event #30 for date: 2025-10-18T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8199
flutter: Event after update - ID: 8199, OriginalID: 8170
flutter: 🔍 DEBUG: Event #30 created with ID: 8199
flutter: 🔍 DEBUG: Creating event #31 for date: 2025-10-21T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8200
flutter: Event after update - ID: 8200, OriginalID: 8170
flutter: 🔍 DEBUG: Event #31 created with ID: 8200
flutter: 🔍 DEBUG: Creating event #32 for date: 2025-10-24T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8201
flutter: Event after update - ID: 8201, OriginalID: 8170
flutter: 🔍 DEBUG: Event #32 created with ID: 8201
flutter: 🔍 DEBUG: Creating event #33 for date: 2025-10-27T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8202
flutter: Event after update - ID: 8202, OriginalID: 8170
flutter: 🔍 DEBUG: Event #33 created with ID: 8202
flutter: 🔍 DEBUG: Creating event #34 for date: 2025-10-30T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8203
flutter: Event after update - ID: 8203, OriginalID: 8170
flutter: 🔍 DEBUG: Event #34 created with ID: 8203
flutter: 🔍 DEBUG: Creating event #35 for date: 2025-11-02T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8204
flutter: Event after update - ID: 8204, OriginalID: 8170
flutter: 🔍 DEBUG: Event #35 created with ID: 8204
flutter: 🔍 DEBUG: Creating event #36 for date: 2025-11-05T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8205
flutter: Event after update - ID: 8205, OriginalID: 8170
flutter: 🔍 DEBUG: Event #36 created with ID: 8205
flutter: 🔍 DEBUG: Creating event #37 for date: 2025-11-08T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8206
flutter: Event after update - ID: 8206, OriginalID: 8170
flutter: 🔍 DEBUG: Event #37 created with ID: 8206
flutter: 🔍 DEBUG: Creating event #38 for date: 2025-11-11T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8207
flutter: Event after update - ID: 8207, OriginalID: 8170
flutter: 🔍 DEBUG: Event #38 created with ID: 8207
flutter: 🔍 DEBUG: Creating event #39 for date: 2025-11-14T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8208
flutter: Event after update - ID: 8208, OriginalID: 8170
flutter: 🔍 DEBUG: Event #39 created with ID: 8208
flutter: 🔍 DEBUG: Creating event #40 for date: 2025-11-17T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8209
flutter: Event after update - ID: 8209, OriginalID: 8170
flutter: 🔍 DEBUG: Event #40 created with ID: 8209
flutter: 🔍 DEBUG: Creating event #41 for date: 2025-11-20T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8210
flutter: Event after update - ID: 8210, OriginalID: 8170
flutter: 🔍 DEBUG: Event #41 created with ID: 8210
flutter: 🔍 DEBUG: Creating event #42 for date: 2025-11-23T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8211
flutter: Event after update - ID: 8211, OriginalID: 8170
flutter: 🔍 DEBUG: Event #42 created with ID: 8211
flutter: 🔍 DEBUG: Creating event #43 for date: 2025-11-26T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8212
flutter: Event after update - ID: 8212, OriginalID: 8170
flutter: 🔍 DEBUG: Event #43 created with ID: 8212
flutter: 🔍 DEBUG: Creating event #44 for date: 2025-11-29T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8213
flutter: Event after update - ID: 8213, OriginalID: 8170
flutter: 🔍 DEBUG: Event #44 created with ID: 8213
flutter: 🔍 DEBUG: Creating event #45 for date: 2025-12-02T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8214
flutter: Event after update - ID: 8214, OriginalID: 8170
flutter: 🔍 DEBUG: Event #45 created with ID: 8214
flutter: 🔍 DEBUG: Creating event #46 for date: 2025-12-05T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8215
flutter: Event after update - ID: 8215, OriginalID: 8170
flutter: 🔍 DEBUG: Event #46 created with ID: 8215
flutter: 🔍 DEBUG: Creating event #47 for date: 2025-12-08T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8216
flutter: Event after update - ID: 8216, OriginalID: 8170
flutter: 🔍 DEBUG: Event #47 created with ID: 8216
flutter: 🔍 DEBUG: Creating event #48 for date: 2025-12-11T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8217
flutter: Event after update - ID: 8217, OriginalID: 8170
flutter: 🔍 DEBUG: Event #48 created with ID: 8217
flutter: 🔍 DEBUG: Creating event #49 for date: 2025-12-14T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8218
flutter: Event after update - ID: 8218, OriginalID: 8170
flutter: 🔍 DEBUG: Event #49 created with ID: 8218
flutter: 🔍 DEBUG: Creating event #50 for date: 2025-12-17T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8219
flutter: Event after update - ID: 8219, OriginalID: 8170
flutter: 🔍 DEBUG: Event #50 created with ID: 8219
flutter: 🔍 DEBUG: Creating event #51 for date: 2025-12-20T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8220
flutter: Event after update - ID: 8220, OriginalID: 8170
flutter: 🔍 DEBUG: Event #51 created with ID: 8220
flutter: 🔍 DEBUG: Creating event #52 for date: 2025-12-23T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8221
flutter: Event after update - ID: 8221, OriginalID: 8170
flutter: 🔍 DEBUG: Event #52 created with ID: 8221
flutter: 🔍 DEBUG: Creating event #53 for date: 2025-12-26T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8222
flutter: Event after update - ID: 8222, OriginalID: 8170
flutter: 🔍 DEBUG: Event #53 created with ID: 8222
flutter: 🔍 DEBUG: Creating event #54 for date: 2025-12-29T00:00:00.000Z
flutter: Creating event with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 3, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Event created with ID: 8223
flutter: Event after update - ID: 8223, OriginalID: 8170
flutter: 🔍 DEBUG: Event #54 created with ID: 8223
flutter: 🔍 DEBUG: Total events generated: 54
flutter: 🔍 DEBUG: addRecurringEvent generated 54 events
flutter: 🔍 DEBUG: addRecurringEvent succeeded, returned 54 events
flutter: 🔍 DEBUG: _addRecurringEvent succeeded, clearing events...
flutter: 🔍 DEBUG: Events cleared, UI will refresh naturally
flutter: 🔍 DEBUG: First event created on: 2025-07-23T00:00:00.000Z
flutter: 🔍 DEBUG: _addRecurringEvent completed
flutter: Event added successfully

