import test from 'node:test';
import assert from 'node:assert/strict';
import {eventOccursOn,isValidEventRange,keyAt,localInputAt,wallTimeToUtc} from '../src/domain.js';

test('converts timezone wall time to a UTC instant and back',()=>{
  const instant=wallTimeToUtc('2026-10-13T09:30','Asia/Kolkata');
  assert.equal(instant.toISOString(),'2026-10-13T04:00:00.000Z');
  assert.equal(localInputAt(instant,'Asia/Kolkata'),'2026-10-13T09:30');
});

test('rejects a local wall time skipped by a daylight-saving transition',()=>{
  assert.throws(()=>wallTimeToUtc('2026-03-08T02:30','America/New_York'),/not valid/);
});

test('events crossing midnight appear on both calendar dates',()=>{
  const event={start_at:'2026-10-13T23:30:00+05:30',end_at:'2026-10-14T00:30:00+05:30'};
  assert.equal(eventOccursOn(event,'2026-10-13','Asia/Kolkata'),true);
  assert.equal(eventOccursOn(event,'2026-10-14','Asia/Kolkata'),true);
});

test('an event ending exactly at midnight does not occupy the next date',()=>{
  const event={start_at:'2026-10-13T23:00:00+05:30',end_at:'2026-10-14T00:00:00+05:30'};
  assert.equal(eventOccursOn(event,'2026-10-14','Asia/Kolkata'),false);
});

test('event end must be strictly after its start',()=>{
  assert.equal(isValidEventRange(new Date('2026-10-13T09:00Z'),new Date('2026-10-13T10:00Z')),true);
  assert.equal(isValidEventRange(new Date('2026-10-13T09:00Z'),new Date('2026-10-13T09:00Z')),false);
});

test('calendar dates use the selected timezone',()=>{
  assert.equal(keyAt(new Date('2026-10-13T20:00:00Z'),'Asia/Kolkata'),'2026-10-14');
});
