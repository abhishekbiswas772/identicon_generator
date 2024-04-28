defmodule IconGen do
  def main(input) do
    input
    |> createHashStringFromName
    |> extractColor
    |> buildGrid
    |> filter_odd_blocks
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def createHashStringFromName(inputName) do
    hashList =
      :crypto.hash(:md5, inputName)
      |> :binary.bin_to_list()

    %IconModel{hex: hashList}
  end

  def draw_image(%IconModel{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)
    Enum.each(pixel_map, fn {x, y} ->
      :egd.filledRectangle(image, x, y, fill)
    end)
    IO.puts("Image Generated .....")
    :egd.render(image)
  end

  def save_image(image, input) do
    IO.puts("Image saved with #{input}.png name .....")
    File.write("./images/#{input}.png", image)
  end

  def build_pixel_map(%IconModel{grid: grid} = image) do
    grid_map_color =
      Enum.map(grid, fn {_value, idx} ->
        horizental_distance = rem(idx, 5) * 50
        vertical_distance = div(idx, 5) * 50
        top_left = {horizental_distance, vertical_distance}
        bottom_right = {horizental_distance + 50, vertical_distance + 50}
        {top_left, bottom_right}
      end)

    %IconModel{image | pixel_map: grid_map_color}
  end


  def filter_odd_blocks(%IconModel{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {value, _idx} ->
        rem(value, 2) == 0
      end)

    %IconModel{image | grid: grid}
  end

  def extractColor(%IconModel{hex: [r, g, b | _tail]} = imgByteList) do
    %IconModel{imgByteList | color: {r, g, b}}
  end

  def buildGrid(%IconModel{hex: hex} = imageStruct) do
    res =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %IconModel{imageStruct | grid: res}
  end

  @spec mirror_row([...]) :: [...]
  def mirror_row([first, mid | _tail] = image_list) do
    image_list ++ [mid, first]
  end
end
