import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";
import ConvertRole from "~/hooks/ConvertRole";
import OnlineService from "~/services/online";
export const GetUserInfo = createAsyncThunk(
  "user/getUserInfo",
  async ({ matk, matkhau }, { rejectWithValue }) => {
    console.log(matk, matkhau);
    try {
      const res = await OnlineService.dangnhap({
        matk: matk,
        matkhau: matkhau,
      });

      return res;
    } catch (err) {
      return rejectWithValue(err.response.data);
    }
  }
);

export const userSlice = createSlice({
  name: "user",
  initialState: {
    ROLE: "online" || "KH" || "NS" || "NV" || "QTV",
    SODT: "",
    MANS: "",
    MAQTV: "",
    MANV: "1",
    HOTEN: "",
    PHAI: "",
    NGAYSINH: "",
    DIACHI: "",
    VITRICV: "",
    loading: false,
    status: "idle",
    error: null,
  },
  reducers: {
    setRole: (state, action) => {
      state.ROLE = action.payload;
    },
    deleteRole: (state) => {
      state.ROLE = "online";
      state.SODT = "";
      state.MANS = "";
      state.MAQTV = "";
      state.MANV = "";
      state.HOTEN = "";
      state.PHAI = "";
      state.NGAYSINH = "";
      state.DIACHI = "";
      state.VITRICV = "";
    },
    updateUserInfo: (state, action) => {
      state.SODT = action.payload.SODT;
      state.MANS = action.payload.MANS;
      state.MANV = action.payload.MANV;
      state.MAQTV = action.payload.MAQTV;
      state.HOTEN = action.payload.HOTEN;
      state.PHAI = action.payload.PHAI;
      state.NGAYSINH = action.payload.NGAYSINH;
      state.DIACHI = action.payload.DIACHI;
      state.VITRICV = action.payload.VITRICV;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(GetUserInfo.pending, (state) => {
        state.loading = true;
        state.status = "loading";
        state.error = null;
      })
      .addCase(GetUserInfo.fulfilled, (state, action) => {
        state.loading = false;
        state.status = "success";
        state.error = null;
      })
      .addCase(GetUserInfo.rejected, (state, action) => {
        state.loading = false;
        state.status = "failed";
        state.error = action.payload;
      });
  },
});
export const { setRole, deleteRole, updateUserInfo } = userSlice.actions;
export default userSlice.reducer;
