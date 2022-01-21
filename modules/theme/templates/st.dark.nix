{ colors }:

with colors; ''
// Base16 <%- scheme %> dark - simple terminal color setup
// <%- author %>
static const char *colorname[] = {
	/* Normal colors */
	"#${base00}", /*  0: Base 00 - Black   */
	"#${base08}", /*  1: Base 08 - Red     */
	"#${base0B}", /*  2: Base 0B - Green   */
	"#${base0A}", /*  3: Base 0A - Yellow  */
	"#${base0D}", /*  4: Base 0D - Blue    */
	"#${base0E}", /*  5: Base 0E - Magenta */
	"#${base0C}", /*  6: Base 0C - Cyan    */
	"#${base05}", /*  7: Base 05 - White   */

	/* Bright colors */
	"#${base03}", /*  8: Base 03 - Bright Black */
	"#${base08}", /*  9: Base 08 - Red          */
	"#${base0B}", /* 10: Base 0B - Green        */
	"#${base0A}", /* 11: Base 0A - Yellow       */
	"#${base0D}", /* 12: Base 0D - Blue         */
	"#${base0E}", /* 13: Base 0E - Magenta      */
	"#${base0C}", /* 14: Base 0C - Cyan         */
	"#${base07}", /* 15: Base 05 - Bright White */

	/* A few more colors */

	"#${base09}", /* 16: Base 09 */
	"#${base0F}", /* 17: Base 0F */
	"#${base01}", /* 18: Base 01 */
	"#${base02}", /* 19: Base 02 */
	"#${base04}", /* 20: Base 04 */
	"#${base06}", /* 21: Base 06 */

	[255] = 0,

	[256] = "#${base05}", /* default fg: Base 05 */
	[257] = "#${base00}", /* default bg: Base 00 */	
};

/*
 * Default colors (colorname index)
 * foreground, background, cursor, reverse cursor
 */
unsigned int defaultfg = 256;
unsigned int defaultbg = 257;
unsigned int defaultcs = 256;
static unsigned int defaultrcs = 257;
''
