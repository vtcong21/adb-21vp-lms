import { createSlice } from "@reduxjs/toolkit";

export const orderSlice = createSlice({
  name: "order",
  initialState: {
    sodt: "",
    mans: "",
    tenns: "",
    sott: "",
    lydokham: "",
    CA: {
      NGAY: "",
      MACA: "",
      GIOBATDAU: "",
      GIOKETTHUC: "",
    },
  },
  reducers: {
    booking: (state, action) => {
      const {
        sodt,
        mans,
        sott,
        lydokham,
        tenns,
        MACA,
        NGAY,
        GIOBATDAU,
        GIOKETTHUC,
      } = action.payload;
      if (tenns !== undefined) {
        state.tenns = tenns;
      }
      if (sodt !== undefined) {
        state.sodt = sodt;
      }
      if (mans !== undefined) {
        state.mans = mans;
      }
      if (sott !== undefined) {
        state.sott = sott;
      }
      if (lydokham !== undefined) {
        state.lydokham = lydokham;
      }
      if (MACA !== undefined) {
        state.CA.MACA = MACA;
      }
      if (NGAY !== undefined) {
        state.CA.NGAY = NGAY;
      }
      if (GIOBATDAU !== undefined) {
        state.CA.GIOBATDAU = GIOBATDAU;
      }
      if (GIOKETTHUC !== undefined) {
        state.CA.GIOKETTHUC = GIOKETTHUC;
      }
    },
    deleteOder: (state) => {
      state.sodt = "";
      state.mans = "";
      state.tenns = "";
      state.sott = "";
      state.lydokham = "";
      state.CA = {
        NGAY: "",
        MACA: "",
        GIOBATDAU: "",
        GIOKETTHUC: "",
      };
    },
  },
});

export const { booking, deleteOder } = orderSlice.actions;
export default orderSlice.reducer;
