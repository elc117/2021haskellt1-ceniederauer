import Text.Printf

type Point     = (Float,Float)
type Rect      = (Point,Float,Float)
type Circle    = (Point,Float)


-------------------------------------------------------------------------------
-- Paletas
-------------------------------------------------------------------------------
allColorsPalette :: Int -> [(Int,Int,Int)]
allColorsPalette n = [fromHSVtoRGB(fromIntegral(m * h))| m <- [0..fromIntegral(n-1)]]
    where h = div 360 n

fromHSVtoRGB :: Float -> (Int, Int, Int)
fromHSVtoRGB h    --                    R                               G                            B
    | h >= 0   && h < 60   = (255                        , truncate(coeficiente * 255), 0                          )
    | h >= 60  && h < 120  = (truncate(coeficiente * 255), 255                        , 0                          )
    | h >= 120 && h < 180  = (0                          , 255                        , truncate(coeficiente * 255))
    | h >= 180 && h < 240  = (0                          , truncate(coeficiente * 255), 255                        )
    | h >= 240 && h < 300  = (truncate(coeficiente * 255), 0                          , 255                        )
    | h >= 300 && h <= 360 = (255                        , 0                          , truncate(coeficiente * 255))
    where coeficiente = (1 - abs(( floatMod (h/60) 2) - 1 ))

floatMod :: Float -> Float -> Float
floatMod x y = x - (y * (fromIntegral $ truncate (x/y)))

greenPalette :: Int -> [(Int,Int,Int)]
greenPalette n = [(0,50+i*6,0) | i <- [0..n] ]

redPalette :: Int -> [(Int,Int,Int)]
redPalette n = [(50+i*6,0,0) | i <- [0..n]]

bluePalette :: Int -> [(Int,Int,Int)]
bluePalette n = [(0,0,50+i*6) | i <- [0..n] ]

greenRedPalette :: Int -> [(Int,Int,Int)] 
greenRedPalette n = [(50+n-i*6,50+i*6,0) | i <- [0..n]]

-- Paleta com n valores retirados de uma lista com sequências de R, G e B 
-- O '$' é uma facilidade sintática que substitui parênteses
-- O cycle é uma função bacana -- procure saber mais sobre ela :-)
rgbPalette :: Int -> [(Int,Int,Int)]
x = redPalette 15 ++  greenPalette 15 ++ bluePalette 15
rgbPalette n = take n $ cycle x
-------------------------------------------------------------------------------
-- Geração de retângulos em suas posições
-------------------------------------------------------------------------------

genRectsInMinhoquinha :: Int -> [Rect]
genRectsInMinhoquinha n  = [((m*(w+gap), 0.0), w, h + gap * cos (m*(1/6 * pi))) | m <- [0..fromIntegral (n-1)]]
  where (w,h) = (25,25)
        gap = 10

-------------------------------------------------------------------------------
-- Strings SVG
-------------------------------------------------------------------------------

-- Gera string representando retângulo SVG 
-- dadas coordenadas e dimensões do retângulo e uma string com atributos de estilo
svgRect :: Rect -> String -> String 
svgRect ((x,y),w,h) style = 
  printf "<rect x='%.3f' y='%.3f' width='%.2f' height='%.2f' style='%s' />\n" x y w h style

-- String inicial do SVG
svgBegin :: Float -> Float -> String
svgBegin w h = printf "<svg width='%.2f' height='%.2f' xmlns='http://www.w3.org/2000/svg'>\n" w h 

-- String final do SVG
svgEnd :: String
svgEnd = "</svg>"

-- Gera string com atributos de estilo para uma dada cor
-- Atributo mix-blend-mode permite misturar cores
svgStyle :: (Int,Int,Int) -> String
svgStyle (r,g,b) = printf "fill:rgb(%d,%d,%d); mix-blend-mode: screen;" r g b

-- Gera strings SVG para uma dada lista de figuras e seus atributos de estilo
-- Recebe uma função geradora de strings SVG, uma lista de círculos/retângulos e strings de estilo
svgElements :: (a -> String -> String) -> [a] -> [String] -> String
svgElements func elements styles = concat $ zipWith func elements styles

-------------------------------------------------------------------------------
-- Função principal que gera arquivo com imagem SVG
-------------------------------------------------------------------------------

main :: IO ()
main = do
  writeFile "minhoquinha.svg" $ svgstrs
  where svgstrs = svgBegin w h ++ svgfigs ++ svgEnd
        svgfigs = svgElements svgRect rects (map svgStyle palette)
        rects = genRectsInMinhoquinha nrects
        palette = rgbPalette nrects 
        nrects = 50
        (w,h) = (1500,500) -- width,height da imagem SVG