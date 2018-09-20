defmodule Identicon do
  @moduledoc """
  Generate and image from a string, yay
  """

  def main(input) do
    input
    |> hash_string
    |> pick_color
    |> build_grid
    |> filter_odd
    |> build_pixel_grid
    |> draw_image
    |> save_image(input)
  end

  def hash_string(str) do
    hex = :crypto.hash(:md5, str)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  # immediate pattern matching
  # this would work too
  # def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    def pick_color(image) do

      # %Identicon.Image{hex: hex_list} = image
      # [r, g, b | _tail] = hex_list

      %Identicon.Image{hex: [r, g, b | _tail]} = image

      %Identicon.Image{image | color: {r, g, b}}
    end

    def build_grid(%Identicon.Image{hex: hex} = image) do
      grid = hex
      |> Enum.drop(-1)
      |> Enum.chunk_every(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

      %Identicon.Image{image | grid: grid }

    end

    def mirror_row(row) do
      # [43, 211, 35]
      [one, two | _tail] = row

      # [43, 211, 35, 211, 43]
      row ++ [two, one]
      # note, to test in console.. set this or you get weird chars
      #  IEx.configure(inspect: [charlists: :as_lists])
    end


    def filter_odd(%Identicon.Image{grid: grid} = image) do
      new_grid = Enum.filter grid, fn({code, _index_dontcare}) ->
        rem(code, 2) == 0
      end
      %Identicon.Image{image | grid: new_grid}
    end

    def build_pixel_grid(%Identicon.Image{grid: grid} = image) do
      # first get the top left values of each square
      grid = Enum.map grid, fn({_meh, index}) ->
        # {top_left_x, top_left_y}
        {rem(index, 5) * 50, div(index, 5) * 50}
      end
      # then get the bottom right values
      pixel_map = Enum.map grid, fn({tlx, tly} = top_left) ->
        {top_left, {tlx + 50, tly + 50}}
      end


      %Identicon.Image{image | pixel_map: pixel_map}


    end

    def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do

      image = :egd.create(250, 250)
      fill = :egd.color(color)

      # tl: top left, br: bottom right
      Enum.each pixel_map, fn({tl, br}) ->
        # note the weird non functional "image" editing
        :egd.filledRectangle(image, tl, br, fill)
      end

      :egd.render(image)
    end

    def save_image(image, filename) do
      File.write("#{filename}.png", image)


    end




    def hello do

      :world
    end
  end
