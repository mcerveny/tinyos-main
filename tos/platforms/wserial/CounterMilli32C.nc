/*
 */
/**
 *
 */

configuration CounterMilli32C
{
  provides interface Counter<TMilli, uint32_t>;
}
implementation
{
  components AlarmCounterMilliP as AlarmCounter;

  Counter = AlarmCounter;
}
