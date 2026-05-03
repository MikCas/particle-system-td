def onReceiveOSC(dat, rowIndex, message, byteData, timeStamp, address, args, peer):
  try:
    # Validate event
    if not address.startswith('/hap/'): return
    if len(args) < 7: return

    # Extract the data
    instrument = address.split('/')[-1] 
    wBegin = args[0]
    wDur = args[1]
    pBegin = args[2]
    pDur = args[3]
    in_cycle = int(args[4])
    pitch = args[5] 
    cps = args[6]

    # Setup event table
    events_table = op('EVENTS')
    if not events_table:
        return
    
    if events_table.numRows == 0 or events_table[0, 0] is None or events_table[0, 0].val != 'cycle':
        events_table.clear()
        events_table.appendRow(['cycle', 'cps', 'instrument', 'wBegin', 'wDur', 'pBegin', 'pDur', 'pitch'])

    # Clear table when new cycle starts
    if events_table.numRows > 1:
        curr_cycle = int(events_table[1, 'cycle'].val)
        
        # New cycle started
        if in_cycle > curr_cycle:
            events_table.clear(keepFirstRow=True)

        # Late message from old cycle - ignore
        elif in_cycle < curr_cycle:
            return 

    # Insert sorted by pitch (ascending) so the GPU shader can do O(N) rank lookup.
    # Walk existing rows to find insertion point.
    insert_at = events_table.numRows  # default: append at end
    for r in range(1, events_table.numRows):
        existing_pitch = float(events_table[r, 'pitch'].val)
        if pitch < existing_pitch:
            insert_at = r
            break

    events_table.insertRow([in_cycle, cps, instrument, wBegin, wDur, pBegin, pDur, pitch], insert_at)
  except Exception as e:
    print(f"[parseOsc] error: {e}")