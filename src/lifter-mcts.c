/*
 * An attempt at a Monte Carlo Tree Search-based lifter for the 2012 ICFPC
 *
 * Julian Squires / 2012
 */

#include <stdlib.h>
#include <stdint.h>

enum { T_EMPTY = 0, T_WALL, T_EARTH, T_ROBOT, T_LAMBDA, T_HOROCK, T_RAZOR, T_BEARD, T_JUMP, T_TARGET, T_LIFT };

typedef struct {
     int n;                     /* n = w*h */
     int water_level, saturation;
     int razors_collected;
     uint8_t map[];
} board;

typedef struct {
     enum { MINING, CRUSHED, DROWNED, ESCAPED };
     int points;
} simulation_result_t;

/* Metadata */
int flooding, waterproof, growth, max_lambdas;
int jumps[9] = {0};
board_t *prior, *future;

int main(void)
{
     /*
       - read map data in temp buffer
       - read metadata
       - connectify:
     - blow away old initial state file
     - mmap a file with enough space for initial state buffer (m*n is
       the maximum)
     - traverse map into initial state buffer, including jump vector
   - create future and prior state buffer as copy of initial
     (maintain original as a file so we can do metasearch)
   - open best log for async appends
   - allocate hash table
   - any allocations after this point will be for the MCTS tree, which
     can be blown away each metasearch.
   - while 1
     - allocate new MCTS tree
     - MCTS
     */
}
