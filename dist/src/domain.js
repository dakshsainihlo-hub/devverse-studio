export function keyAt(date, timezone) {
  const parts = Object.fromEntries(new Intl.DateTimeFormat('en-CA', {timeZone:timezone,year:'numeric',month:'2-digit',day:'2-digit'}).formatToParts(date).map(x=>[x.type,x.value]));
  return `${parts.year}-${parts.month}-${parts.day}`;
}

export function localInputAt(date, timezone) {
  const parts = Object.fromEntries(new Intl.DateTimeFormat('en-CA', {timeZone:timezone,year:'numeric',month:'2-digit',day:'2-digit',hour:'2-digit',minute:'2-digit',hourCycle:'h23'}).formatToParts(date).map(x=>[x.type,x.value]));
  return `${parts.year}-${parts.month}-${parts.day}T${parts.hour}:${parts.minute}`;
}

export function wallTimeToUtc(value, timezone) {
  const match=value.match(/^(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d)$/);
  if(!match) throw new Error('Choose a valid event date and time.');
  const desired=Date.UTC(+match[1],+match[2]-1,+match[3],+match[4],+match[5]);
  let time=desired;
  for(let i=0;i<4;i++){
    const parts=Object.fromEntries(new Intl.DateTimeFormat('en-CA',{timeZone:timezone,year:'numeric',month:'2-digit',day:'2-digit',hour:'2-digit',minute:'2-digit',hourCycle:'h23'}).formatToParts(new Date(time)).map(x=>[x.type,x.value]));
    time+=desired-Date.UTC(+parts.year,+parts.month-1,+parts.day,+parts.hour,+parts.minute);
  }
  const result=new Date(time);
  if(localInputAt(result,timezone)!==value) throw new Error('That local time is not valid in your selected timezone.');
  return result;
}

export function eventOccursOn(event, day, timezone) {
  const start=new Date(event.start_at),end=new Date(event.end_at),startDay=keyAt(start,timezone),endDay=keyAt(end,timezone);
  return startDay<=day&&(endDay>day||(endDay===day&&localInputAt(end,timezone).slice(11)!=='00:00'));
}

export function isValidEventRange(start, end) {
  return Number.isFinite(start.getTime()) && Number.isFinite(end.getTime()) && end > start;
}
