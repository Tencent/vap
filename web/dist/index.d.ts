import { VapConfig } from './type';
import WebglRenderVap from './webgl-render-vap';
/**
 * @param options
 * @constructor
 * @return {null}
 */
export default function (options?: VapConfig): WebglRenderVap;
export declare function canWebGL(): boolean;
