
float[][][] grid;
float[][][] next;

float dA = 1;
float dB = 0.5;
float feed = 0.055;
float k = 0.062;

long t_start;

int stageW;
int stageH;
float stageScale;

void setup()
{
  size(1000,1000);
  
  frameRate(30);
  
  stageScale = 6;
  stageW = floor( width / stageScale );
  stageH = floor( height / stageScale );
  
  t_start = millis();
  
  grid = new float[stageW][][];
  next = new float[stageW][][];
  
  for(int x = 0; x < stageW; x++)
  {
    grid[x] = new float[stageH][];
    next[x] = new float[stageH][];
    
    for(int y = 0; y < stageH; y++)
    {
      grid[x][y] = new float[2];
      next[x][y] = new float[2];
      
      grid[x][y][0] = 1;
      grid[x][y][1] = 0;
      next[x][y][0] = 1;
      next[x][y][1] = 0;
    }
  }
  
  keyPressed();
}

void setRect( int xx, int yy, int w, int h, float c )
{
  for(int x = xx; x < xx+w; x++)
  {
    for(int y = yy; y < yy+h; y++)
    {
      int gx = constrain( x, 0, stageW-1 );
      int gy = constrain( y, 0, stageW-1 );
      
      grid[gx][gy][1] = c;
    }
  }
}

void keyPressed() 
{
  int w = floor( random( stageW * 0.1, stageW * 0.6 ) );
  int h = floor( random( stageH * 0.1, stageH * 0.6 ) );
  
  int x = floor( random( 0, stageW ) - ( w / 2 ) );
  int y = floor( random( 0, stageH ) - ( h / 2 ) );
  
  float c = random(0,1);
  setRect( x, y, w, h, c );
}

void draw()
{
  background(0);
  
  float t = (millis() - t_start);
  dA = sin(t/3000) * 0.15 + 0.90;
  dB = sin(t/1000) * 0.2 + 0.33;
  
  for ( int i = 0 ; i < 6; i++ )
  {
    reactionDiffusion();
    swap();
  }
  
  for(int x = 0; x < stageW; x++)
  {
    for(int y = 0; y < stageH; y++)
    {
      float a = next[x][y][0];
      float b = next[x][y][1];
      int c = floor( ( a - b ) * ( 255 * 2 ) ) - 50;
      c = constrain( c, 0, 255 );
      c = c > 40 ? 255 : 0;
      color clr = color( c, c, c );
      
      for ( int sx = 0; sx < stageScale - 3; sx++ )
      {
        for ( int sy = 0; sy < stageScale - 0; sy++ )
        {
          set( floor( x * stageScale ) + sx, floor( y * stageScale ) + sy, clr );
        }
      }
      
      
    }
  }
  
}


void reactionDiffusion()
{
  float a;
  float b;
  
  for(int x = 1; x < stageW-1; ++x)
  {
    for(int y = 1; y < stageH-1; ++y)
    {
      a = grid[x][y][0];
      b = grid[x][y][1];
      
      next[x][y][0] = a +  
                      ( dA * laplaceA( x, y ) ) - 
                      ( a * b * b ) +
                      ( feed * ( 1 - a ) );
                      
      next[x][y][1] = b +  
                      ( dB * laplaceB( x, y ) ) + 
                      ( a * b * b ) -
                      ( ( k + feed ) * b );
                      
      next[x][y][0] = constrain( next[x][y][0], 0, 1 );
      next[x][y][1] = constrain( next[x][y][1], 0, 1 );
    }
  }
}


float e1 = -1;
float e2 = 0.2;
float e3 = 0.05;

float laplaceA(int x, int y)
{
  float sumA = 0;
  sumA += grid[x][y][0] * e1;
  sumA += grid[x-1][y][0] * e2;
  sumA += grid[x+1][y][0] * e2;
  sumA += grid[x][y+1][0] * e2;
  sumA += grid[x][y-1][0] * e2;
  sumA += grid[x-1][y-1][0] * e3;
  sumA += grid[x+1][y-1][0] * e3;
  sumA += grid[x-1][y+1][0] * e3;
  sumA += grid[x+1][y+1][0] * e3;
  return sumA;
}

float laplaceB(int x, int y)
{
  float sumB = 0;
  sumB += grid[x][y][1] * e1;
  sumB += grid[x-1][y][1] * e2;
  sumB += grid[x+1][y][1] * e2;
  sumB += grid[x][y+1][1] * e2;
  sumB += grid[x][y-1][1] * e2;
  sumB += grid[x-1][y-1][1] * e3;
  sumB += grid[x+1][y-1][1] * e3;
  sumB += grid[x-1][y+1][1] * e3;
  sumB += grid[x+1][y+1][1] * e3;
  return sumB;
}

void swap()
{
  float[][][] temp = grid;
  grid = next;
  next = temp;
}
