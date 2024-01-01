import { CtSHello, StCHello } from "./Hello";
import { CtSValue, StCValue } from "./Value";

export type CtSBaseMessage = CtSHello | CtSValue;

export type StCBaseMessage = StCHello | StCValue;
