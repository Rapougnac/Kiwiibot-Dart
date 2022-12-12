package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"bytes"
	"encoding/json"
	"image"
	"image/draw"
	"image/gif"
	"image/png"
	"math"
	"strings"
	"unicode"
	"unsafe"

	"os"

	"github.com/golang/freetype"
)

var fontBytes, _ = os.ReadFile("OpenSans.ttf")
var font, _ = freetype.ParseFont(fontBytes)
var c = freetype.NewContext()

func AddTextToImage(img draw.Image, dst draw.Image, x, y int, text string, maxLength float64) error {
	c.SetFont(font)
	c.SetSrc(img)
	c.SetDst(dst)
	size := 18.
	c.SetFontSize(size)
	c.SetClip(img.Bounds())
	// c.SetDPI(maxLength)
	pt := freetype.Pt(x, y+int(c.PointToFixed(size)>>6))

	t := strings.Split(text, "\n")

	for _, s := range t {
		_, err := c.DrawString(s, pt)
		if err != nil {
			return err
		}

		pt.Y += c.PointToFixed(size * 1.5)
	}

	return nil
}

func main() {
	// f, _ := Illegal(C.CString("./test_lib/illegal"), C.CString("CRINGING\nIS NOW\nILLEGAL"))
	// fmt.Println(string(f))
	// fmt.Println(f)
	// C.free(f)
}

type FramesFile struct {
	Corners [][]float64 `json:"corners"`
	Cile    string      `json:"file"`
	Show    bool        `json:"show"`
}

//export Illegal
func Illegal(d, t *C.char) (unsafe.Pointer /*[]byte*/, C.int /*int*/) {
	dirToOpen := C.GoString(d)
	text := C.GoString(t)
	framesFile, eralal := os.ReadFile("frames.json")
	if eralal != nil {
		panic(eralal)
	}
	var frames []FramesFile
	e := json.Unmarshal(framesFile, &frames)
	if e != nil {
		panic(e)
	}

	files, err := os.ReadDir(dirToOpen)
	if err != nil {
		panic(err)
	}
	var filenames []string
	for _, file := range files {
		filenames = append(filenames, file.Name())
	}

	anim := gif.GIF{LoopCount: len(filenames)}
	for i, filename := range filenames {
		reader, err := os.Open(dirToOpen + "/" + filename)
		if err != nil {
			panic(err)
		}
		defer reader.Close()

		img, err := png.Decode(reader)
		if err != nil {
			panic(err)
		}
		bounds := img.Bounds()
		drawer := draw.FloydSteinberg

		palettedImg := image.NewPaletted(bounds, img.(*image.Paletted).Palette)

		if frames[i].Show {
			err = AddTextToImage(palettedImg, img.(draw.Image), int(frames[i].Corners[0][0]), int(frames[i].Corners[0][1]), text, math.Abs(frames[i].Corners[1][0])-(frames[i].Corners[0][0]))
		}

		if err != nil {
			panic(err)
		}

		drawer.Draw(palettedImg, img.Bounds(), img, image.Point{})

		anim.Image = append(anim.Image, palettedImg)
		anim.Delay = append(anim.Delay, 0)
	}

	buffer := new(bytes.Buffer)
	encodeErr := gif.EncodeAll(buffer, &anim)
	if encodeErr != nil {
		panic(encodeErr)
	}

	return C.CBytes(buffer.Bytes()), C.int(len(buffer.Bytes()))
}

const nbsp = 0xA0

func WrapString(s string, lim uint) string {
	// Initialize a buffer with a slightly larger size to account for breaks
	init := make([]byte, 0, len(s))
	buf := bytes.NewBuffer(init)

	var current uint
	var wordBuf, spaceBuf bytes.Buffer
	var wordBufLen, spaceBufLen uint

	for _, char := range s {
		if char == '\n' {
			if wordBuf.Len() == 0 {
				if current+spaceBufLen > lim {
					current = 0
				} else {
					current += spaceBufLen
					spaceBuf.WriteTo(buf)
				}
				spaceBuf.Reset()
				spaceBufLen = 0
			} else {
				current += spaceBufLen + wordBufLen
				spaceBuf.WriteTo(buf)
				spaceBuf.Reset()
				spaceBufLen = 0
				wordBuf.WriteTo(buf)
				wordBuf.Reset()
				wordBufLen = 0
			}
			buf.WriteRune(char)
			current = 0
		} else if unicode.IsSpace(char) && char != nbsp {
			if spaceBuf.Len() == 0 || wordBuf.Len() > 0 {
				current += spaceBufLen + wordBufLen
				spaceBuf.WriteTo(buf)
				spaceBuf.Reset()
				spaceBufLen = 0
				wordBuf.WriteTo(buf)
				wordBuf.Reset()
				wordBufLen = 0
			}

			spaceBuf.WriteRune(char)
			spaceBufLen++
		} else {
			wordBuf.WriteRune(char)
			wordBufLen++

			if current+wordBufLen+spaceBufLen > lim && wordBufLen < lim {
				buf.WriteRune('\n')
				current = 0
				spaceBuf.Reset()
				spaceBufLen = 0
			}
		}
	}

	if wordBuf.Len() == 0 {
		if current+spaceBufLen <= lim {
			spaceBuf.WriteTo(buf)
		}
	} else {
		spaceBuf.WriteTo(buf)
		wordBuf.WriteTo(buf)
	}

	return buf.String()
}
